/*
 *  Toolchain.cpp
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

#include <SMCE/Toolchain.hpp>

#include <string>
#include <system_error>
#include <boost/predef.h>
#include <boost/process.hpp>
#if BOOST_OS_WINDOWS
#include <boost/process/windows.hpp>
#endif
#include <SMCE/internal/utils.hpp>
#include <SMCE/Sketch.hpp>
#include <SMCE/SketchConf.hpp>

using namespace std::literals;

namespace bp = boost::process;

namespace std {
template <>
struct is_error_code_enum<smce::toolchain_error> : std::bool_constant<true> {};
} // std

namespace smce {
namespace detail {

struct toolchain_error_category : public std::error_category {
public:
    const char* name() const noexcept override {
        return "smce.toolchain";
    }

    std::string message(int ev) const override {
        switch(static_cast<toolchain_error>(ev)) {
        case toolchain_error::resdir_absent: return "Resource directory does not exist";
        case toolchain_error::resdir_empty: return "Resource directory empty";
        case toolchain_error::resdir_file: return "Resource directory is a file";
        case toolchain_error::cmake_not_found: return "CMake not found in PATH";
        case toolchain_error::sketch_invalid: return "Sketch path is invalid";
        case toolchain_error::configure_failed: return "CMake configure failed";
        case toolchain_error::build_failed: return "CMake build failed";
        default: return "smce.toolchain error";
        }
    }

    std::error_condition default_error_condition(int ev) const noexcept override {
        return std::error_condition{ev, *this};
    }

    bool equivalent(int ev, const std::error_condition& condition) const noexcept override {
        return condition.value() == ev && &condition.category() == this;
    }

    bool equivalent(const std::error_code& error, int ev) const noexcept override {
        return error.value() == ev && &error.category() == this;
    }
};

const std::error_category& get_exec_ctx_error_category() noexcept {
    static const toolchain_error_category cat{};
    return cat;
}

} // detail

inline std::error_code make_error_code(toolchain_error ev){
    return std::error_code{
        static_cast<std::underlying_type<toolchain_error>::type>(ev),
        detail::get_exec_ctx_error_category()};
}

struct ProcessedLibs {
    std::string pp_remote_arg = "-DPREPROC_REMOTE_LIBS=";
    std::string cl_remote_arg = "-DCOMPLINK_REMOTE_LIBS=";
    std::string cl_local_arg = "-DCOMPLINK_LOCAL_LIBS=";
    std::string cl_patch_arg = "-DCOMPLINK_PATCH_LIBS=";
};
ProcessedLibs process_libraries(const SketchConfig& skonf) noexcept {
    ProcessedLibs ret;
    for (const auto& lib : skonf.preproc_libs) {
        std::visit(Visitor{
            [&](const SketchConfig::RemoteArduinoLibrary& lib){
              ret.pp_remote_arg += lib.name;
              if(!lib.version.empty())
                  ret.pp_remote_arg += '@' + lib.version;
              ret.pp_remote_arg += ';';
            },
            [](const auto&) {}
        }, lib);
    }

    for (const auto& lib : skonf.complink_libs) {
        std::visit(Visitor{
            [&](const SketchConfig::RemoteArduinoLibrary& lib){
              ret.cl_remote_arg += lib.name;
              if(!lib.version.empty())
                  ret.cl_remote_arg += '@' + lib.version;
              ret.cl_remote_arg += ';';
            },
            [&](const SketchConfig::LocalArduinoLibrary& lib){
              if(lib.patch_for.empty()) {
                  ret.cl_local_arg += lib.root_dir.string();
                  ret.cl_local_arg += ';';
                  return;
              }
              ret.cl_remote_arg += lib.patch_for;
              ret.cl_remote_arg += ' ';
              ret.cl_patch_arg += lib.root_dir.string();
              ret.cl_patch_arg += '|';
              ret.cl_patch_arg += lib.patch_for;
              ret.cl_patch_arg += ';';
            },
            [](const SketchConfig::FreestandingLibrary&) {}
        }, lib);
    }

    if(ret.pp_remote_arg.back() == ';') ret.pp_remote_arg.pop_back();
    if(ret.cl_remote_arg.back() == ';') ret.cl_remote_arg.pop_back();
    if(ret.cl_local_arg.back() == ';') ret.cl_local_arg.pop_back();
    if(ret.cl_patch_arg.back() == ';') ret.cl_patch_arg.pop_back();

    return ret;
}

Toolchain::Toolchain(stdfs::path resources_dir) noexcept : m_res_dir{std::move(resources_dir)} {
    m_build_log.reserve(4096);
}

std::error_code Toolchain::do_configure(Sketch& sketch) noexcept {
#if !BOOST_OS_WINDOWS
    const char* const generator_override = std::getenv("CMAKE_GENERATOR");
    const char* const generator = generator_override ? generator_override : (!bp::search_path("ninja").empty() ? "Ninja" : "");
#endif

    ProcessedLibs libs = process_libraries(sketch.m_conf);

    namespace bp = boost::process;
    bp::ipstream cmake_conf_out;
    auto cmake_config = bp::child(
        m_cmake_path,
#if !BOOST_OS_WINDOWS
        bp::env["CMAKE_GENERATOR"] = generator,
#endif
        "-DSMCE_DIR=" + m_res_dir.string(),
        "-DSKETCH_FQBN=" + sketch.m_conf.fqbn,
        "-DSKETCH_PATH=" + stdfs::absolute(sketch.m_source).generic_string(),
        std::move(libs.pp_remote_arg),
        std::move(libs.cl_remote_arg),
        std::move(libs.cl_local_arg),
        std::move(libs.cl_patch_arg),
        "-P",
        m_res_dir.string() + "/RtResources/SMCE/share/Scripts/ConfigureSketch.cmake",
        (bp::std_out & bp::std_err) > cmake_conf_out
#if BOOST_OS_WINDOWS
       ,bp::windows::create_no_window
#endif
    );

    {
        std::string line;
        int i = 0;
        while (std::getline(cmake_conf_out, line)) {
            if (!line.starts_with("-- SMCE: ")) {
                [[maybe_unused]] std::lock_guard lk{m_build_log_mtx};
                (m_build_log += line) += '\n';
                continue;
            }
            line.erase(0, line.find_first_of('"') + 1);
            line.pop_back();
            switch (i++) {
            case 0:
                sketch.m_tmpdir = std::move(line);
                break;
            case 1:
                sketch.m_executable = std::move(line);
                break;
            default:
                assert(false);
            }
        }
    }

    cmake_config.join();
    if (cmake_config.native_exit_code() != 0)
        return toolchain_error::configure_failed;
    return {};
}

std::error_code Toolchain::do_build(Sketch& sketch) noexcept {
    bp::ipstream cmake_build_out;
    auto cmake_build = bp::child{
#if BOOST_OS_WINDOWS
        bp::env["MSBUILDDISABLENODEREUSE"] = "1", // MSBuild "feature" which uses your child processes as potential deamons, forever
#endif
        m_cmake_path,
        "--build", (sketch.m_tmpdir / "build").string(),
        "--config", "Release",
        (bp::std_out & bp::std_err) > cmake_build_out
#if BOOST_OS_WINDOWS
       ,bp::windows::create_no_window
#endif
    };

    for (std::string line; std::getline(cmake_build_out, line);) {
        [[maybe_unused]] std::lock_guard lk{m_build_log_mtx};
        (m_build_log += line) += '\n';
    }

    cmake_build.join();
    if(cmake_build.native_exit_code() != 0)
        return toolchain_error::build_failed;

    std::error_code ec;
    const bool binary_exists = stdfs::exists(sketch.m_executable, ec);
    if(ec)
        return ec;
    if(!binary_exists)
        return toolchain_error::build_failed;
    return {};
}

[[nodiscard]] std::error_code Toolchain::check_suitable_environment() noexcept {
    if(std::error_code ec; !stdfs::exists(m_res_dir, ec))
        return toolchain_error::resdir_absent;
    else if(ec)
        return ec;

    if(std::error_code ec; !stdfs::is_directory(m_res_dir, ec))
        return toolchain_error::resdir_file;
    else if(ec)
        return ec;

    if(std::error_code ec; stdfs::is_empty(m_res_dir, ec))
        return toolchain_error::resdir_empty;
    else if(ec)
        return ec;

    if(m_cmake_path != "cmake") {
        if(std::error_code ec; stdfs::is_empty(m_cmake_path, ec))
            return toolchain_error::cmake_not_found;
        else if(ec)
            return ec;
    } else {
        m_cmake_path = bp::search_path(m_cmake_path).string();
        if(m_cmake_path.empty())
            return toolchain_error::cmake_not_found;
    }
    bp::ipstream cmake_out;
    bp::child cmake_child{
        m_cmake_path,
        "--version",
        bp::std_out > cmake_out
#if BOOST_OS_WINDOWS
       ,bp::windows::create_no_window
#endif
    };
    std::string line;
    while (cmake_child.running() && std::getline(cmake_out, line) && !line.empty()) {
        if(!line.starts_with("cmake")) {
            cmake_child.join();
            return toolchain_error::cmake_unknown_output;
        }
        break;
    }
    cmake_child.join();
    if(cmake_child.native_exit_code() != 0)
        return toolchain_error::cmake_failing;
    return {};
}


std::error_code Toolchain::compile(Sketch& sketch) noexcept {
    sketch.m_built = false;
    std::error_code ec;

    const bool source_exists = stdfs::exists(sketch.m_source, ec);
    if(ec)
        return ec;
    if(!source_exists)
        return toolchain_error::sketch_invalid;

    if(sketch.m_conf.fqbn.empty())
        return toolchain_error::sketch_invalid;

    ec = do_configure(sketch);
    if(ec)
        return ec;
    ec = do_build(sketch);
    if(ec)
        return ec;

    sketch.m_built = true;
    return {};
}

}