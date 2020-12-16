/*
 *  Dummy.hxx
 *  Copyright 2020 ItJustWorksTM
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

#include "Dummy.hxx"

using namespace godot;

auto Dummy::_init() -> void {
    Godot::print("Dummy initted");
}

auto Dummy::_ready() -> void {
    Godot::print("Dummy ready");
}

auto Dummy::_process(float) -> void {
    this->set_process(false);
}