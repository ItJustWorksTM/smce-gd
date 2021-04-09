/*
 *  ExecutionContext.hpp
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

#ifndef SMCE_EXECUTIONCONTEXT_HPP
#define SMCE_EXECUTIONCONTEXT_HPP

#include <system_error>
#include <SMCE/fwd.hpp>
#include <SMCE/SMCE_fs.hpp>

namespace smce {

enum struct exec_ctx_error {
    no_res_dir = 1,
    cmake_not_found,
    cmake_unknown_output,
    cmake_failing,
    generic = 255
};

/**
 * The context of execution for sketches in board-runners
 *
 * Ideally there should only ever be one instance of this type
 * used at a given type in an application.
 **/
class ExecutionContext {
    stdfs::path m_res_dir;
    std::string m_cmake_path = "cmake";

  public:
    /**
     * Constructor
     * \param resources_dir - path to the SMCE resources directory (inflated SMCE_Resources.zip)
     **/
    explicit ExecutionContext(stdfs::path resources_dir) : m_res_dir{std::move(resources_dir)} {};

    /// Getter for the SMCE resource directory
    [[nodiscard]] const stdfs::path& resource_dir() const noexcept { return m_res_dir; }
    /// Getter for the CMake path
    [[nodiscard]] const std::string& cmake_path() const noexcept { return m_cmake_path; }

    /**
     * Checks whether the required tools are provided
     *
     * \warning This function currently only checks for CMake's availability through the PATH env var
     * \todo Extend to check for a C++ >=11 compiler
     **/
    [[nodiscard]] std::error_code check_suitable_environment() noexcept;
};

}

#endif // SMCE_EXECUTIONCONTEXT_HPP
