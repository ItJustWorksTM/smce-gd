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

class ExecutionContext {
    stdfs::path m_res_dir;

  public:
    explicit ExecutionContext(stdfs::path resources_dir) : m_res_dir{std::move(resources_dir)} {};
    [[nodiscard]] const stdfs::path& resource_dir() const noexcept { return m_res_dir; }
    [[nodiscard]] bool check_suitable_environment() noexcept;
};

}

#endif // SMCE_EXECUTIONCONTEXT_HPP
