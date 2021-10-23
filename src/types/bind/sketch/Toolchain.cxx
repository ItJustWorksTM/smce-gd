/*
 *  Toolchain.cxx
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

#include <filesystem>
#include "Toolchain.hxx"

using namespace godot;

Ref<Result> Toolchain::init(String resource_dir) {
    if (is_initialized())
        return Result::err("Already initialized");

    // TODO: properly absolute-ize path, this could throw I think
    tc = std::make_shared<smce::Toolchain>(std::filesystem::absolute(std_str(resource_dir)));
    const auto res = Result::from(tc->check_suitable_environment());

    if (res->is_err())
        tc.reset();

    reader = make_ref<ToolchainLogReader>();
    reader->tc = tc;

    m_resource_dir = resource_dir;

    return res;
}

void Toolchain::_register_methods() {
    register_method("compile", &Toolchain::compile);
    register_method("is_initialized", &Toolchain::is_initialized);
    register_method("init", &Toolchain::init);
    register_method("log_reader", &Toolchain::log_reader);
    register_method("_to_string", &Toolchain::_to_string);
}

Ref<Result> Toolchain::compile(Ref<Sketch> sketch) {
    if (!is_initialized())
        return Result::err("Toolchain not initialized");

    return Result::from(tc->compile(sketch->native()));
}

void ToolchainLogReader::_register_methods() { register_method("read", &ToolchainLogReader::read); }

Variant ToolchainLogReader::read() {
    if (!tc)
        return Variant{};
    if (auto [_, str] = tc->build_log(); !str.empty()) {
        auto ret = String{str.c_str()};
        str.clear();

        return ret;
    }
    return Variant{};
}

String Toolchain::_to_string() {
    return String{"Toolchain {"} + " resource_dir: \"" + m_resource_dir + "\" }";
}