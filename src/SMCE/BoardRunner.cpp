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
#include <fcntl.h>
#include <csignal>
#elif BOOST_OS_WINDOWS
#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include <namedpipeapi.h>
#pragma comment(lib, "Kernel32.lib")
#include <winternl.h>
#pragma comment(lib, "ntdll.lib")
extern "C" {
__declspec(dllimport) LONG NTAPI NtResumeProcess(HANDLE ProcessHandle);
__declspec(dllimport) LONG NTAPI NtSuspendProcess(HANDLE ProcessHandle);
}
#else
#error "Unsupported platform"
#endif

#include <ctime>
#include <string>
#include <boost/process.hpp>
#include <SMCE/BoardConf.hpp>
#include <SMCE/BoardView.hpp>
#include <SMCE/ExecutionContext.hpp>
#include <SMCE/internal/SharedBoardData.hpp>
#include <SMCE/internal/utils.hpp>

using namespace std::literals;
namespace bp = boost::process;
namespace bip = boost::interprocess;

namespace smce {

enum class BoardRunner::Command {
    run,      // <==>
    stop,     // ==>
    suspend,  // ==>
    stop_ack, // <==
};

struct BoardRunner::Internal {
    std::uint64_t sketch_id = std::time(nullptr);
    SharedBoardData sbdata;
    bp::child sketch;
    bp::ipstream sketch_log;
};

BoardRunner::BoardRunner(ExecutionContext& ctx, std::function<void(int)> exit_notify) noexcept
    : m_exectx{ctx}
    , m_exit_notify{std::move(exit_notify)}
    , m_internal{std::make_unique<Internal>()}
{}

BoardRunner::~BoardRunner() {
    if (m_internal && m_internal->sketch.valid() && m_internal->sketch.running())
        m_internal->sketch.terminate();
    if (!m_sketch_dir.empty()) {
        [[maybe_unused]] std::error_code ec;
        stdfs::remove_all(m_sketch_dir, ec);
    }
}

[[nodiscard]] BoardView BoardRunner::view() noexcept {
    if (m_status != Status::configured && m_status != Status::built && m_status != Status::running && m_status != Status::suspended)
        return {};
    return BoardView{*m_internal->sbdata.get_board_data()};
}

void BoardRunner::tick() noexcept {
   switch (m_status) {
   case Status::running:
   case Status::suspended:
       if (!m_internal->sketch.running()) {
           m_status = Status::stopped;
           if (m_exit_notify)
               m_exit_notify(m_internal->sketch.exit_code());
       }
   default:
       ;
   }
}

bool BoardRunner::reset() noexcept {
    switch (m_status) {
    case Status::running:
    case Status::suspended:
        return false;
    default:
        if (m_internal && m_internal->sketch.valid() && m_internal->sketch.running())
            m_internal->sketch.terminate();
        m_internal = std::make_unique<Internal>();
        if (!m_sketch_dir.empty())
            stdfs::remove_all(m_sketch_dir);
        m_sketch_dir = stdfs::path{};
        m_sketch_bin = stdfs::path{};
        m_build_log = std::stringstream{};
        m_status = Status::clean;
        return true;
    }
}

bool BoardRunner::configure(std::string_view pp_fqbn, const BoardConfig& bconf) noexcept {
    if (!(m_status == Status::clean || m_status == Status::configured))
        return false;

    namespace bp = boost::process;

    m_internal->sbdata.configure("SMCE-Runner-" + std::to_string(m_internal->sketch_id), pp_fqbn, bconf);
    m_status = Status::configured;
    return true;
}

bool BoardRunner::build(const stdfs::path& sketch_src, const SketchConfig& skonf) noexcept {
    const auto& res_path = m_exectx.resource_dir();
    const auto& cmake_path = m_exectx.cmake_path();

    std::string dir_arg = "-DSMCE_DIR=" + res_path.string();
    std::string fqbn_arg = "-DSKETCH_FQBN="s + m_internal->sbdata.get_board_data()->fqbn.c_str();
    std::string sketch_arg = "-DSKETCH_PATH=" + stdfs::absolute(sketch_src).generic_string();
    std::string pp_remote_libs_arg = "-DPREPROC_REMOTE_LIBS=";
    std::string cl_remote_libs_arg = "-DCOMPLINK_REMOTE_LIBS=";
    std::string cl_local_libs_arg = "-DCOMPLINK_LOCAL_LIBS=";
    std::string cl_patch_libs_arg = "-DCOMPLINK_PATCH_LIBS=";
    for (const auto& lib : skonf.preproc_libs) {
        std::visit(Visitor{
           [&](const SketchConfig::RemoteArduinoLibrary& lib){
               pp_remote_libs_arg += lib.name;
               if(!lib.version.empty())
                   pp_remote_libs_arg += '@' + lib.version;
             pp_remote_libs_arg += ';';
           },
           [](const auto&) {}
        }, lib);
    }

    for (const auto& lib : skonf.complink_libs) {
        std::visit(Visitor{
            [&](const SketchConfig::RemoteArduinoLibrary& lib){
                cl_remote_libs_arg += lib.name;
                if(!lib.version.empty())
                    cl_remote_libs_arg += '@' + lib.version;
                cl_remote_libs_arg += ';';
            },
            [&](const SketchConfig::LocalArduinoLibrary& lib){
                if(lib.patch_for.empty()) {
                    cl_local_libs_arg += lib.root_dir.string();
                    cl_local_libs_arg += ';';
                    return;
                }
                cl_remote_libs_arg += lib.patch_for;
                cl_remote_libs_arg += ' ';
                cl_patch_libs_arg += lib.root_dir.string();
                cl_patch_libs_arg += '|';
                cl_patch_libs_arg += lib.patch_for;
                cl_patch_libs_arg += ';';
            },
            [](const SketchConfig::FreestandingLibrary&) {}
        }, lib);
    }

    if(pp_remote_libs_arg.back() == ';') pp_remote_libs_arg.pop_back();
    if(cl_remote_libs_arg.back() == ';') cl_remote_libs_arg.pop_back();
    if(cl_local_libs_arg.back() == ';') cl_local_libs_arg.pop_back();
    if(cl_patch_libs_arg.back() == ';') cl_patch_libs_arg.pop_back();

    namespace bp = boost::process;
    bp::ipstream cmake_conf_out;
    bp::ipstream cmake_conf_err;
    auto cmake_config = bp::child(
        cmake_path,
        std::move(dir_arg),
        std::move(fqbn_arg),
        std::move(sketch_arg),
        std::move(pp_remote_libs_arg),
        std::move(cl_remote_libs_arg),
        std::move(cl_local_libs_arg),
        std::move(cl_patch_libs_arg),
        "-P",
        res_path.string() + "/RtResources/SMCE/share/Scripts/ConfigureSketch.cmake",
        (bp::std_out & bp::std_err) > cmake_conf_out
    );

    {
        std::string line;
        int i = 0;
        while (std::getline(cmake_conf_out, line)) {
            if (!line.starts_with("-- SMCE: ")) {
                m_build_log << line << std::endl;
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
    m_build_log.flush();
    if (cmake_config.native_exit_code() != 0)
        return false;

    bp::ipstream cmake_build_out;
    const int build_res = bp::system(
#if BOOST_OS_WINDOWS
        bp::env["MSBUILDDISABLENODEREUSE"] = "1", // MSBuild "feature" which uses your child processes as potential deamons, forever
#endif
        cmake_path,
        "--build",
        (m_sketch_dir / "build").string(),
        (bp::std_out & bp::std_err) > cmake_build_out
    );

    m_build_log << cmake_build_out.rdbuf();
    m_build_log.flush();

    if (build_res != 0 || !stdfs::exists(m_sketch_bin))
        return false;

    std::error_code ec;

    m_status = Status::built;
    return !static_cast<bool>(ec);
}

bool BoardRunner::start() noexcept {
    if (m_status != Status::built)
        return false;

    m_internal->sketch =
        bp::child(
            bp::env["SEGNAME"] = "SMCE-Runner-" + std::to_string(m_internal->sketch_id),
            "\""+m_sketch_bin.string()+"\"",
            bp::std_out > bp::null,
            bp::std_err > m_internal->sketch_log
    );
#if BOOST_OS_UNIX || BOOST_OS_MACOS
    ::fcntl(m_internal->sketch_log.pipe().native_source(), F_SETFL, O_NONBLOCK);
#elif BOOST_OS_WINDOWS
    DWORD pmode = PIPE_NOWAIT;
    ::SetNamedPipeHandleState(m_internal->sketch_log.pipe().native_source(), &pmode, nullptr, nullptr);
#endif
    m_status = Status::running;
    return true;
}

bool BoardRunner::suspend() noexcept {
    if (m_status != Status::running)
        return false;

#if defined(__unix__)
    ::kill(m_internal->sketch.native_handle(), SIGSTOP);
#elif defined(_WIN32) || defined(WIN32)
    NtSuspendProcess(m_internal->sketch.native_handle());
#endif

    m_status = Status::suspended;
    return true;
}

bool BoardRunner::resume() noexcept {
    if (m_status != Status::suspended)
        return false;

#if defined(__unix__)
    ::kill(m_internal->sketch.native_handle(), SIGCONT);
#elif defined(_WIN32) || defined(WIN32)
    NtResumeProcess(m_internal->sketch.native_handle());
#endif

    m_status = Status::running;
    return true;
}

bool BoardRunner::terminate() noexcept {
    if (m_status != Status::running && m_status != Status::suspended)
        return false;

    std::error_code ec;
    m_internal->sketch.terminate(ec);
    if (!ec)
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

// FIXME
bool BoardRunner::stop() noexcept { return terminate(); }

static std::istream null_istream{nullptr};
std::istream& BoardRunner::runtime_log() noexcept {
    if (m_status == Status::running
        || m_status == Status::suspended
        || m_status == Status::stopped)
        return m_internal->sketch_log;
    return null_istream;
}

}
