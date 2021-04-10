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

#include <string>
#include <system_error>

#include <boost/process.hpp>

namespace bp = boost::process;



namespace std {
template <>
struct is_error_code_enum<smce::exec_ctx_error> : std::bool_constant<true> {};
} // std

namespace smce {
namespace detail {

struct exec_ctx_error_category : public std::error_category {
public:
    const char* name() const noexcept override {
        return "smce.exec_ctx";
    }

    std::string message(int ev) const override {
        switch(static_cast<exec_ctx_error>(ev)) {
        case exec_ctx_error::resdir_absent: return "Resource directory does not exist";
        case exec_ctx_error::resdir_empty: return "Resource directory empty";
        case exec_ctx_error::resdir_file: return "Resource directory is a file";
        case exec_ctx_error::cmake_not_found: return "CMake not found in PATH";
        default: return "smce.exec_ctx error";
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
    static const exec_ctx_error_category cat{};
    return cat;
}

} // detail

inline std::error_code make_error_code(exec_ctx_error ev){
    return std::error_code{
        static_cast<std::underlying_type<exec_ctx_error>::type>(ev),
        detail::get_exec_ctx_error_category()};
}

[[nodiscard]] std::error_code ExecutionContext::check_suitable_environment() noexcept {
    if(std::error_code ec; !stdfs::exists(m_res_dir, ec))
        return exec_ctx_error::resdir_absent;
    else if(ec)
        return ec;

    if(std::error_code ec; !stdfs::is_directory(m_res_dir, ec))
        return exec_ctx_error::resdir_file;
    else if(ec)
        return ec;

    if(std::error_code ec; stdfs::is_empty(m_res_dir, ec))
        return exec_ctx_error::resdir_empty;
    else if(ec)
        return ec;

    if(m_cmake_path != "cmake") {
        if(std::error_code ec; stdfs::is_empty(m_cmake_path, ec))
            return exec_ctx_error::cmake_not_found;
        else if(ec)
            return ec;
    } else {
        m_cmake_path = bp::search_path(m_cmake_path).string();
        if(m_cmake_path.empty())
            return exec_ctx_error::cmake_not_found;
    }
    bp::ipstream cmake_out;
    bp::child cmake_child{m_cmake_path, "--version", bp::std_out > cmake_out};
    std::string line;
    while (cmake_child.running() && std::getline(cmake_out, line) && !line.empty()) {
        if(!line.starts_with("cmake")) {
            cmake_child.join();
            return exec_ctx_error::cmake_unknown_output;
        }
        break;
    }
    cmake_child.join();
    if(cmake_child.native_exit_code() != 0)
        return exec_ctx_error::cmake_failing;
    return {};
}

}