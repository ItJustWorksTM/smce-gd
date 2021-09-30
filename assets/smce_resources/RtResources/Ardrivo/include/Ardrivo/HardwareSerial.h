/*
 *  HardwareSerial.h
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

#ifndef HardwareSerial_h
#define HardwareSerial_h

#include <array>
#include <cstddef>
#include <cstdint>
#include "SMCE_dll.hpp"
#include "Stream.h"

#define SERIAL_5N1 0x00
#define SERIAL_6N1 0x02
#define SERIAL_7N1 0x04
#define SERIAL_8N1 0x06
#define SERIAL_5N2 0x08
#define SERIAL_6N2 0x0A
#define SERIAL_7N2 0x0C
#define SERIAL_8N2 0x0E
#define SERIAL_5E1 0x20
#define SERIAL_6E1 0x22
#define SERIAL_7E1 0x24
#define SERIAL_8E1 0x26
#define SERIAL_5E2 0x28
#define SERIAL_6E2 0x2A
#define SERIAL_7E2 0x2C
#define SERIAL_8E2 0x2E
#define SERIAL_5O1 0x30
#define SERIAL_6O1 0x32
#define SERIAL_7O1 0x34
#define SERIAL_8O1 0x36
#define SERIAL_5O2 0x38
#define SERIAL_6O2 0x3A
#define SERIAL_7O2 0x3C
#define SERIAL_8O2 0x3E

struct SMCE_HardwareSerialImpl;
struct SMCE__DLL_RT_API HardwareSerial : Stream {
    void begin(unsigned long, std::uint8_t = SERIAL_8N1);
    void end();

    [[nodiscard]] int available() override;
    [[nodiscard]] int read() override;
    [[nodiscard]] int peek() override;

    [[nodiscard]] int availableForWrite() override;

    size_t write(std::uint8_t) override;
    size_t write(const std::uint8_t*, size_t) override;
    inline size_t write(unsigned long n) { return write((std::uint8_t)n); }
    inline size_t write(long n) { return write((std::uint8_t)n); }
    inline size_t write(unsigned int n) { return write((std::uint8_t)n); }
    inline size_t write(int n) { return write((std::uint8_t)n); }
    using Print::write;
    [[nodiscard]] constexpr /* explicit(false) */ operator bool() noexcept { return true; }

  private:
    friend SMCE_HardwareSerialImpl;
};

extern SMCE__DLL_RT_API HardwareSerial& Serial;

#define HAVE_HWSERIAL0

#endif // HardwareSerial_h