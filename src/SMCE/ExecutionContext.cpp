/*
 *  ExecutionContext.cpp
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

#include <SMCE/ExecutionContext.hpp>

#include <boost/process.hpp>

namespace bp = boost::process;

namespace smce {

[[nodiscard]] bool ExecutionContext::check_suitable_environment() noexcept {
    if(std::error_code ec; stdfs::is_empty(m_res_dir, ec) || ec)
        return false;

    if(m_cmake_path != "cmake") {
        if(std::error_code ec; stdfs::is_empty(m_cmake_path, ec) || ec)
            return false;
    } else {
        m_cmake_path = bp::search_path(m_cmake_path).string();
        if(m_cmake_path.empty())
            return false;
    }
    bp::ipstream cmake_out;
    bp::child cmake_child{m_cmake_path, "--version", bp::std_out > cmake_out};
    std::string line;
    while (cmake_child.running() && std::getline(cmake_out, line) && !line.empty()) {
        if(!line.starts_with("cmake")) {
            cmake_child.join();
            return false;
        }
        break;
    }
    cmake_child.join();
    return cmake_child.native_exit_code() == 0;
}

}