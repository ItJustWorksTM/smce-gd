/*
 *  ExecutionContext.cxx
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

#include "bind/ExecutionContext.hxx"
#include "gd/util.hxx"

using namespace godot;

void ExecutionContext::_register_methods() {
    register_method("resource_dir", &ExecutionContext::resource_dir);
    register_method("check_suitable_environment", &ExecutionContext::check_suitable_environment);
}

Ref<ExecutionContext> ExecutionContext::make_context(String path) {
    auto ret = make_ref<ExecutionContext>();
    ret->context =
        smce::ExecutionContext{std::string_view{path.alloc_c_string(), static_cast<size_t>(path.length())}};
    return ret;
}

void ExecutionContext::_init() { Godot::print("ExecutionContext created"); }

// Allocates full String, so dont use :)
String ExecutionContext::resource_dir() { return context.resource_dir().c_str(); }

bool ExecutionContext::check_suitable_environment() { return ! static_cast<bool>(context.check_suitable_environment()); }

smce::ExecutionContext& ExecutionContext::native() { return context; }
