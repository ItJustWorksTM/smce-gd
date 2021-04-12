/*
 *  Toolchain.hpp
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

#ifndef SMCE_TOOLCHAIN_HPP
#define SMCE_TOOLCHAIN_HPP

#include <mutex>
#include <string>
#include <system_error>
#include <SMCE/fwd.hpp>
#include <SMCE/SMCE_fs.hpp>
#include <SMCE/Sketch.hpp>

namespace smce {

enum struct toolchain_error {
    resdir_absent = 1,
    resdir_file,
    resdir_empty,
    cmake_not_found,
    cmake_unknown_output,
    cmake_failing,

    sketch_invalid,
    configure_failed,
    build_failed,

    generic = 255
};

/**
 * The context of execution for sketches in board-runners
 *
 * Ideally there should only ever be one instance of this type
 * used at a given type in an application.
 **/
class Toolchain {
    stdfs::path m_res_dir;
    std::string m_cmake_path = "cmake";

    std::string m_build_log;
    std::mutex m_build_log_mtx;

    std::error_code do_configure(Sketch& sketch) noexcept;
    std::error_code do_build(Sketch& sketch) noexcept;

  public:
    using LockedLog = std::pair<std::unique_lock<std::mutex>, std::string&>;

    /**
     * Constructor
     * \param resources_dir - path to the SMCE resources directory (inflated SMCE_Resources.zip)
     **/
    explicit Toolchain(stdfs::path resources_dir) noexcept;

    /// Getter for the SMCE resource directory
    [[nodiscard]] const stdfs::path& resource_dir() const noexcept { return m_res_dir; }
    /// Getter for the CMake path
    [[nodiscard]] const std::string& cmake_path() const noexcept { return m_cmake_path; }

    [[nodiscard]] inline LockedLog build_log() noexcept { return {std::unique_lock{m_build_log_mtx}, m_build_log}; }

    /**
     * Checks whether the required tools are provided
     *
     * \warning This function currently only checks for CMake's availability through the PATH env var
     * \todo Extend to check for a C++ >=11 compiler
     **/
    [[nodiscard]] std::error_code check_suitable_environment() noexcept;

    /**
     * Compile a sketch
     **/
     std::error_code compile(Sketch& sketch) noexcept;
};

}

#endif // SMCE_TOOLCHAIN_HPP
