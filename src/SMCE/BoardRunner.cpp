/*
 *  BoardRunner.cpp
 *  Copyright 2021 ItJustWorksTM
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

#include <boost/predef.h>
#include <SMCE/BoardRunner.hpp>

#if BOOST_OS_UNIX || BOOST_OS_MACOS
#include <csignal>
#elif BOOST_OS_WINDOWS
#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include <winternl.h>
extern "C" {
LONG NTAPI NtSuspendProcess(HANDLE ProcessHandle);
LONG NTAPI NtResumeProcess(HANDLE ProcessHandle);
}
#else
#error "Unsupported platform"
#endif

#include <ctime>
#include <iostream>
#include <mutex>
#include <span>
#include <string>
#include <boost/process.hpp>
#include <boost/interprocess/managed_shared_memory.hpp>
#include <SMCE/BoardConf.hpp>
#include <SMCE/BoardView.hpp>
#include <SMCE/internal/SharedBoardData.hpp>

using namespace std::literals;
namespace bp = boost::process;
namespace bip = boost::interprocess;

namespace smce {

enum class BoardRunner::Command {
    run, // <==>
    stop, // ==>
    suspend, // ==>
    stop_ack, // <==
};

struct BoardRunner::Internal {
    std::uint64_t sketch_id = std::time(nullptr);
    SharedBoardData sbdata;
    bp::child sketch;
};

BoardRunner::BoardRunner(ExecutionContext& ctx) noexcept : m_exectx{ctx} {
    m_internal = std::make_unique<Internal>();
}

BoardRunner::~BoardRunner() {
    if(m_internal && m_internal->sketch.valid() && m_internal->sketch.running())
        m_internal->sketch.terminate();
    if(!m_sketch_dir.empty())
        stdfs::remove_all(m_sketch_dir);
}

[[nodiscard]] BoardView BoardRunner::view() noexcept {
    if(m_status != Status::configured && m_status != Status::built && m_status != Status::running && m_status != Status::suspended)
        return {};
    return BoardView{*m_internal->sbdata.get_board_data()};
}

bool BoardRunner::reset() noexcept {
    switch(m_status) {
    case Status::running:
    case Status::suspended:
        return false;
    default:
        if(m_internal
          && m_internal->sketch.valid()
          && m_internal->sketch.running())
            m_internal->sketch.terminate();
        m_internal = std::make_unique<Internal>();
        if(!m_sketch_dir.empty())
            stdfs::remove_all(m_sketch_dir);
        m_sketch_dir = stdfs::path{};
        m_sketch_bin = stdfs::path{};
        m_status = Status::clean;
        return true;
    }
}

bool BoardRunner::configure(std::string_view pp_fqbn, const BoardConfig& bconf) noexcept {
    if(!(m_status == Status::clean || m_status == Status::configured))
        return false;

    namespace bp = boost::process;

    m_internal->sbdata.configure("SMCE-Runner-" + std::to_string(m_internal->sketch_id), pp_fqbn, bconf);
    m_status = Status::configured;
    return true;
}

bool BoardRunner::build(const stdfs::path& sketch_src, [[maybe_unused]] const SketchConfig& skonf) noexcept {
    const auto& res_path = m_exectx.resource_dir();
    const auto& cmake_path = m_exectx.cmake_path();

    std::string dir_arg = "-DSMCE_DIR=" + res_path.string();
    std::string fqbn_arg = "-DSKETCH_FQBN="s + m_internal->sbdata.get_board_data()->fqbn.c_str();
    std::string sketch_arg = "-DSKETCH_PATH=" + stdfs::absolute(sketch_src).string();

    namespace bp = boost::process;
    bp::ipstream cmake_out;
    auto cmake_config = bp::child(
        cmake_path,
        std::move(dir_arg),
        std::move(fqbn_arg),
        std::move(sketch_arg),
        "-P",
        res_path.string() + "/RtResources/SMCE/share/Scripts/ConfigureSketch.cmake",
        bp::std_out > cmake_out
    );

    {
        std::string line;
        int i = 0;
        while (std::getline(cmake_out, line)) {
            if (!line.starts_with("-- SMCE: ")) {
                std::cout << line << std::endl;
                continue;
            }
            line.erase(0, line.find_first_of('"') + 1);
            line.pop_back();
            switch (i++) {
            case 0:
                m_sketch_dir = std::move(line);
                break;
            case 1:
                m_sketch_bin = std::move(line);
                break;
            default:
                assert(false);
            }
        }
    }

    cmake_config.join();

    if(cmake_config.native_exit_code() != 0)
        return false;

    const int build_res = bp::system(cmake_path, "--build", (m_sketch_dir / "build").string());

    if(build_res != 0 || !stdfs::exists(m_sketch_bin))
        return false;

    std::error_code ec;

    m_status = Status::built;
    return !static_cast<bool>(ec);
}

bool BoardRunner::start() noexcept {
    if(m_status != Status::built)
        return false;

    m_internal->sketch =
        bp::child(
            bp::env["SEGNAME"] = "SMCE-Runner-" + std::to_string(m_internal->sketch_id),
            m_sketch_bin.string(),
            bp::on_exit([&](int, const std::error_code&){
                m_status = Status::stopped;
            }));
    m_status = Status::running;
    return true;
}

bool BoardRunner::suspend() noexcept {
    if(m_status != Status::running)
        return false;

#if defined(__unix__)
    ::kill(m_internal->sketch.id(), SIGSTOP);
#elif defined(_WIN32) || defined(WIN32)
    NtSuspendProcess(m_internal->sketch.id());
#endif

    m_status = Status::suspended;
    return true;
}

bool BoardRunner::resume() noexcept {
    if(m_status != Status::suspended)
        return false;

#if defined(__unix__)
    ::kill(m_internal->sketch.id(), SIGCONT);
#elif defined(_WIN32) || defined(WIN32)
    NtResumeProcess(m_internal->sketch.id());
#endif

    m_status = Status::running;
    return true;
}

bool BoardRunner::terminate() noexcept {
    if(m_status != Status::running
        && m_status != Status::suspended)
        return false;

    std::error_code ec;
    m_internal->sketch.terminate(ec);
    if(!ec)
        m_status = Status::stopped;
    return !ec;
}

/*
bool BoardRunner::stop() noexcept {
    if(m_status != Status::running)
        return false;

    auto& command = m_internal->command;
    command = Command::stop;
    command.notify_all();

    const auto val = command.wait(Command::stop);
    const bool success = val == Command::stop_ack;
    if(success)
        m_status = Status::stopped;

    return success;
}
*/

//FIXME
bool BoardRunner::stop() noexcept { return terminate(); }

}