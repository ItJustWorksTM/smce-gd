/*
 *  Arduino.cpp
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
#include <iostream>
#include <thread>
#include "Ardrivo/Arduino.h"
#include "SMCE/BoardView.hpp"

namespace smce {
extern BoardView board_view;
extern void maybe_init();
} // namespace smce

using namespace smce;

void pinMode(int pin, bool mode) {
    auto error = [=](const char* msg) {
        std::cerr << "ERROR: pinMode(" << pin << ", " << (mode ? "OUTPUT" : "INPUT") << "): " << msg << std::endl;
    };
    maybe_init();
    auto vpin = board_view.pins[pin];

    if (!vpin.exists())
        return error("Pin does not exist");
    if (vpin.locked())
        return error("Pin is in use by another device");

    vpin.set_direction(static_cast<VirtualPin::DataDirection>(+mode));
}

int digitalRead(int pin) {
    auto error = [=](const char* msg) {
        return std::cerr << "ERROR: digitalRead(" << pin << "): " << msg << std::endl, 0;
    };
    maybe_init();
    auto vpin = board_view.pins[pin];

    if (!vpin.exists())
        return error("Pin does not exist");
    if (!vpin.digital().can_read())
        return error("Pin has no digital driver capable of reading");
    if (vpin.locked())
        return error("Pin is in use by another device");
    if (vpin.get_direction() != VirtualPin::DataDirection::in)
        return error("Pin is in output mode");

    return vpin.digital().read();
}

void digitalWrite(int pin, bool value) {
    auto error = [=](const char* msg) {
        std::cerr << "ERROR: digitalWrite(" << pin << ", " << (value ? "HIGH" : "LOW") << "): " << msg << std::endl;
    };
    maybe_init();
    auto vpin = board_view.pins[pin];

    if (!vpin.exists())
        return error("Pin does not exist");
    if (!vpin.digital().can_write())
        return error("Pin has no digital driver capable of reading");
    if (vpin.locked())
        return error("Pin is in use by another device");
    if (vpin.get_direction() != VirtualPin::DataDirection::out)
        return error("Pin is in input mode");

    vpin.digital().write(value);
}

int analogRead(int pin) {
    auto error = [=](const char* msg) {
        return std::cerr << "ERROR: analogRead(" << pin << "): " << msg << std::endl, 0;
    };
    maybe_init();
    auto vpin = board_view.pins[pin];

    if (!vpin.exists())
        return error("Pin does not exist");
    if (!vpin.analog().can_read())
        return error("Pin has no analog driver capable of reading");
    if (vpin.locked())
        return error("Pin is in use by another device");
    if (vpin.get_direction() != VirtualPin::DataDirection::in)
        return error("Pin is in output mode");

    return vpin.analog().read();
}

void analogWrite(int pin, byte value) {
    auto error = [=](const char* msg) {
        std::cerr << "ERROR: analogWrite(" << pin << ", " << static_cast<int>(value) << "): " << msg << std::endl;
    };
    maybe_init();
    auto vpin = board_view.pins[pin];

    if (!vpin.exists())
        return error("Pin does not exist");
    if (!vpin.analog().can_write())
        return error("Pin has no analog driver capable of reading");
    if (vpin.locked())
        return error("Pin is in use by another device");
    if (vpin.get_direction() != VirtualPin::DataDirection::out)
        return error("Pin is in input mode");

    vpin.analog().write(value);
}

void delay(unsigned long long ms) { std::this_thread::sleep_for(std::chrono::milliseconds{ms}); }

void delayMicroseconds(unsigned long long us) { std::this_thread::sleep_for(std::chrono::microseconds{us}); }

static const auto start_time = std::chrono::steady_clock::now();

unsigned long micros() {
    const auto current_time = std::chrono::steady_clock::now();
    return static_cast<unsigned long>(
        std::chrono::duration_cast<std::chrono::microseconds>(current_time - start_time).count());
}

unsigned long millis() {
    const auto current_time = std::chrono::steady_clock::now();
    return static_cast<unsigned long>(
        std::chrono::duration_cast<std::chrono::milliseconds>(current_time - start_time).count());
}