/*
 *  Future.cxx
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

#include <chrono>
#include "Future.hxx"

using namespace godot;

void Promise::_register_methods() {
    register_method("set_value", &Promise::set_value);
    register_method("get_future", &Promise::get_future);
}

void Promise::_init() {
    future = make_ref<Future>();
    future->future = promise.get_future();
}

void Promise::set_value(Variant value) {
    promise.set_value(value);
    future->call_deferred("emit_signal", "complete");
}

void Future::_register_methods() {
    register_method("wait", &Future::wait);
    register_method("poll_ready", &Future::poll_ready);
    register_method("get", &Future::get);
    register_signal<Future>("complete");
}

bool Future::poll_ready() { return future.wait_for(std::chrono::seconds(0)) == std::future_status::ready; }
