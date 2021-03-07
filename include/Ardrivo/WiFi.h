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
    inline int connect([[maybe_unused]] IPAddress ip, [[maybe_unused]] uint16_t port) override { assert(false); }
    int connect([[maybe_unused]] const char* host, [[maybe_unused]] uint16_t port) override { assert(false); }
    size_t write([[maybe_unused]] uint8_t) override { assert(false); }
    size_t write([[maybe_unused]] const uint8_t* buf, [[maybe_unused]] size_t size) override { assert(false); }
    int available() override { assert(false); }
    int read() override { assert(false); }
    int read([[maybe_unused]] uint8_t* buf, [[maybe_unused]] size_t size) override { assert(false); }
    int peek() override { assert(false); }
    void flush() override { assert(false); }
    void stop() override { assert(false); }
    uint8_t connected() override { assert(false); }
    operator bool() override { assert(false); }
};

SMCE__DLL_RT_API
extern WiFiClass WiFi;

#endif // WiFi_h
