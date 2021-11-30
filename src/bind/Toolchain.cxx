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

#include <iostream>
#include "bind/Toolchain.hxx"

using namespace godot;

#define STR(s) #s
#define U(f)                                                                                                 \
    std::pair { STR(f), &Toolchain::f }

void Toolchain::_register_methods() {
    register_fns(U(init), U(resource_dir), U(check_suitable_environment), U(check_cmake_availability), U(cmake_path),
                  U(compile), U(set_free), U(is_building), U(_physics_process), U(get_log), U(find_compilers));
    register_signals<Toolchain>("building", "built", "log");
}

void Toolchain::CompilerInformation::_register_methods() {
    register_property("name", &CompilerInformation::name, String{});
    register_property("path", &CompilerInformation::path, String{});
    register_property("version", &CompilerInformation::version, String{});
}

#undef STR
#undef U

void Toolchain::_init() { set_physics_process(false); }

Ref<GDResult> Toolchain::init(String resource_dir) {
    tc.emplace(std_str(resource_dir));
    auto res = tc->check_suitable_environment();
    return GDResult::from(res);
}

void Toolchain::_physics_process() {
    auto [_, str] = tc->build_log();

    if (!building && str.empty())
        set_physics_process(false);

    if (str.empty())
        return;

    emit_signal("log", String{str.c_str()});
    log += str.c_str();
    std::cout << str;

    str.clear();
}

String Toolchain::resource_dir() { return tc->resource_dir().c_str(); }

Ref<GDResult> Toolchain::check_suitable_environment() {
    return GDResult::from(tc->check_suitable_environment());
}

Ref<GDResult> Toolchain::check_cmake_availability() {
    return GDResult::from(tc->check_cmake_availability());
}

String Toolchain::cmake_path() { return tc->cmake_path().c_str(); }

String Toolchain::get_log() { return log; }

bool Toolchain::compile(Ref<Sketch> sketch) {
    if (building || sketch.is_null())
        return false;
    building = true;
    log = "";

    emit_signal("building", sketch);
    set_physics_process(true);

    Godot::print("making awaitable");
    AnyTask::make_awaitable(
        [&, sketch]() mutable {
            Godot::print("Async compile started");
            return GDResult::from(tc->compile(sketch->native()));
        },
        [&, sketch](Ref<GDResult> res) mutable {
            Godot::print("Async compile ended");
            building = false;
            emit_signal("built", sketch, res);
            if (res->is_ok())
                sketch->emit_signal("compiled");
            if (queued_free)
                queue_free();
        });
    return true;
}

void Toolchain::set_free() {
    queued_free = true;
    if (building)
        return Godot::print("Warning: BoardRunner queued to be freed while still building");
    queue_free();
}

Array Toolchain::find_compilers() {
    Array result;

    auto compilerDefault = make_ref<Toolchain::CompilerInformation>();
    compilerDefault->name = "Default compiler";
    compilerDefault->path = "";
    compilerDefault->version = "";
    result.push_back(compilerDefault);

    auto compilers = tc->find_compilers();
    for (const smce::Toolchain::CompilerInformation ci : compilers) {
        auto compiler = make_ref<Toolchain::CompilerInformation>();
        compiler->name = ci.name.c_str();
        compiler->path = ci.path.c_str();
        compiler->version = ci.version.c_str();
        result.push_back(compiler);
    };

    return result;
}
