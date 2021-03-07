/*
 *  WiFi.h
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

#ifndef WiFi_h
#define WiFi_h

#include <cassert>
#include "Client.h"
#include "IPAddress.h"
#include "SMCE_dll.hpp"

struct WiFiClass : Client {
    [[noreturn]] inline int connect([[maybe_unused]] IPAddress ip, [[maybe_unused]] uint16_t port) override { assert(false); }
    [[noreturn]] int connect([[maybe_unused]] const char* host, [[maybe_unused]] uint16_t port) override { assert(false); }
    [[noreturn]] size_t write([[maybe_unused]] uint8_t) override { assert(false); }
    [[noreturn]] size_t write([[maybe_unused]] const uint8_t* buf, [[maybe_unused]] size_t size) override { assert(false); }
    [[noreturn]] int available() override { assert(false); }
    [[noreturn]] int read() override { assert(false); }
    [[noreturn]] int read([[maybe_unused]] uint8_t* buf, [[maybe_unused]] size_t size) override { assert(false); }
    [[noreturn]] int peek() override { assert(false); }
    [[noreturn]] void flush() override { assert(false); }
    [[noreturn]] void stop() override { assert(false); }
    [[noreturn]] uint8_t connected() override { assert(false); }
    [[noreturn]] operator bool() override { assert(false); }
};

SMCE__DLL_RT_API
extern WiFiClass WiFi;

#endif // WiFi_h
