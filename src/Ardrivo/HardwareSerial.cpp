/*
 *  HardwareSerial.cpp
 *  Copyright 2020-2021 ItJustWorksTM
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

#include <deque>
#include <iostream>
#include <limits>
#include "HardwareSerial.h"
#include "SMCE_dll.hpp"

static const char* env_pipes_root(){
    const auto* env_val = std::getenv("SMCE_ROOT");
    return env_val ? env_val : ".";
}

struct SMCE_HardwareSerialImpl : HardwareSerial {
    explicit SMCE_HardwareSerialImpl(int id) : m_id{id} {}
    const int m_id;
    std::deque<char> m_buf;
    bool m_begun = false;
};

SMCE_HardwareSerialImpl Serial_impl{0};
SMCE__DLL_API HardwareSerial& Serial{Serial_impl};

constexpr SMCE_HardwareSerialImpl& upcast(HardwareSerial& obj) {
    return static_cast<SMCE_HardwareSerialImpl&>(obj); // NOLINT
}

void HardwareSerial::begin(unsigned long, uint8_t) {
//  maybe_init();
    upcast(*this).m_begun = true;
}

void HardwareSerial::end() { upcast(*this).m_begun = false; }

int HardwareSerial::available() {
    if(!upcast(*this).m_begun)
        return 0;
    return upcast(*this).m_buf.size();
}

int HardwareSerial::availableForWrite() { return std::numeric_limits<int>::max(); }

size_t HardwareSerial::write(uint8_t c) {
    if (!upcast(*this).m_begun)
        return 0;
    std::cout.put(c);
    return 1;
}

size_t HardwareSerial::write(const uint8_t* buf, std::size_t n) {
    if (!upcast(*this).m_begun)
        return 0;
    std::cout.write(reinterpret_cast<const char*>(buf), n);
    return n;
}

int HardwareSerial::peek() {
    if (!upcast(*this).m_begun)
        return -1;
    return std::cin.peek();
}

int HardwareSerial::read() {
    if (!upcast(*this).m_begun || available() == 0)
        return -1;
    return std::cin.get();
}