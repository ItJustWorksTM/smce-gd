/*
 *  BrushedMotor.hxx
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

#include "virt_devices/BrushedMotor.hxx"

using namespace godot;

void BrushedMotor::_register_methods() {
    register_method("get_speed", &BrushedMotor::get_speed);
    register_method("set_boardview", &BrushedMotor::set_boardview);
    register_method("set_pins", &BrushedMotor::set_pins);
    register_method("_on_view_invalidated", &BrushedMotor::_on_view_invalidated);
}

void BrushedMotor::_init() { }

float BrushedMotor::get_speed() {
    if (!board_view)
        return 0;
    
    auto bv = board_view->native();
    const auto abs_throttle = bv.pins[enable_pin].analog().read();
    const auto forward = bv.pins[forward_pin].digital().read();
    const auto backward = bv.pins[backward_pin].digital().read();

    const auto throttle = (abs_throttle / 255.0f) * (forward - backward);

    return throttle;
}

void BrushedMotor::set_boardview(BoardView* view) {
    if (!view)
        return;
    view->connect("tree_exiting", this, "_on_view_invalidated");
    board_view = view;
}

void BrushedMotor::_on_view_invalidated() {
    board_view = nullptr;
}

void BrushedMotor::set_pins(int enable_pin, int forward_pin, int backward_pin) {
    this->enable_pin = enable_pin;
    this->forward_pin = forward_pin;
    this->backward_pin = backward_pin;
}
