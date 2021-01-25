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

#include <iostream>
#include <limits>
#include <SMCE/BoardView.hpp>
#include "HardwareSerial.h"
#include "SMCE_dll.hpp"

namespace smce {
extern BoardView board_view;
extern void maybe_init();
}

using namespace smce;

struct SMCE_HardwareSerialImpl : HardwareSerial {
    explicit SMCE_HardwareSerialImpl(int id) noexcept : m_id{id} {}
    const int m_id;
    VirtualUart view() noexcept { maybe_init(); return board_view.uart_channels[m_id]; }
};

SMCE_HardwareSerialImpl Serial_impl{0};
SMCE__DLL_API HardwareSerial& Serial{Serial_impl};

constexpr SMCE_HardwareSerialImpl& upcast(HardwareSerial& obj) {
    return static_cast<SMCE_HardwareSerialImpl&>(obj); // NOLINT
}

void HardwareSerial::begin([[maybe_unused]] unsigned long baud_rate, [[maybe_unused]] uint8_t conf) {
    upcast(*this).view().set_active(true);
}

void HardwareSerial::end() {
    if(!upcast(*this).view().is_active())
        return (void)(std::cerr << "HardwareSerial::end(): Already inactive" << std::endl);
    upcast(*this).view().set_active(false);
}

int HardwareSerial::available() {
    if(!upcast(*this).view().is_active())
        return std::cerr << "HardwareSerial::available(): Device inactive" << std::endl, 0;
    return upcast(*this).view().rx().size();
}

int HardwareSerial::availableForWrite() {
    if(!upcast(*this).view().is_active())
        return std::cerr << "HardwareSerial::availableForWrite(): Device inactive" << std::endl, 0;
    auto tx_buf = upcast(*this).view().tx();
    return static_cast<int>(tx_buf.max_size() - tx_buf.size());
}

size_t HardwareSerial::write(uint8_t c) {
    if(!upcast(*this).view().is_active())
        return std::cerr << "HardwareSerial::write(" << static_cast<int>(c) << "): Device inactive" << std::endl, 0;
    return upcast(*this).view().tx().write({reinterpret_cast<const char*>(&c), 1});
}

size_t HardwareSerial::write(const uint8_t* buf, std::size_t n) {
    if(!upcast(*this).view().is_active())
        return std::cerr << "HardwareSerial::write(?, " << n << "): Device inactive" << std::endl, 0;
    return upcast(*this).view().tx().write({reinterpret_cast<const char*>(buf), n});
}

int HardwareSerial::peek() {
    if(!upcast(*this).view().is_active())
        return std::cerr << "HardwareSerial::peek(): Device inactive" << std::endl, -1;
    if(upcast(*this).view().rx().size() < 1)
        return -1;
    return upcast(*this).view().rx().front();
}

int HardwareSerial::read() {
    if(!upcast(*this).view().is_active())
        return std::cerr << "HardwareSerial::read(): Device inactive" << std::endl, -1;
    char ret;
    if(upcast(*this).view().rx().read({&ret, 1}))
        return ret;
    return -1;
}