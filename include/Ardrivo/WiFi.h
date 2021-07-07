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

#include <cstdint>
#include "Client.h"
#include "IPAddress.h"
#include "SMCE_dll.hpp"

struct WiFiClass : Client {
    inline int connect([[maybe_unused]] IPAddress ip, [[maybe_unused]] std::uint16_t port) override { return 0; }
    int connect([[maybe_unused]] const char* host, [[maybe_unused]] std::uint16_t port) override { return 0; }
    std::size_t write([[maybe_unused]] std::uint8_t) override { return 0; }
    std::size_t write([[maybe_unused]] const std::uint8_t* buf, [[maybe_unused]] std::size_t size) override {
        return 0;
    }
    int available() override { return 0; }
    int read() override { return -1; }
    int read([[maybe_unused]] std::uint8_t* buf, [[maybe_unused]] std::size_t size) override { return 0; }
    int peek() override { return -1; }
    void flush() override {}
    void stop() override {}
    std::uint8_t connected() override { return 0; }
    operator bool() override { return false; }
};

SMCE__DLL_RT_API
extern WiFiClass WiFi;

#endif // WiFi_h
