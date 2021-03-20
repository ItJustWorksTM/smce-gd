/*
 *  Print.cpp
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
 */


#include "Print.h"

Print::Print() noexcept = default;

void Print::setWriteError(int err) noexcept { write_error = err; }

int Print::getWriteError() noexcept { return write_error; }
void Print::clearWriteError() noexcept { setWriteError(0); }

std::size_t Print::write(const uint8_t* buffer, std::size_t size) {
    const auto beg = buffer;
    while (size-- && write(*buffer++))
        ;
    return std::distance(beg, buffer);
}

std::size_t Print::write(const char* str) {
    if (!str)
        return 0;
    return write(str, std::strlen(str));
}

std::size_t Print::write(const char* buffer, size_t size) {
    return write(reinterpret_cast<const std::uint8_t*>(buffer), size);
}

// default to zero, meaning "a single write may block"
int Print::availableForWrite() { return 0; }

std::size_t Print::print(const String& s) { return write(s.c_str(), s.length()); }
std::size_t Print::print(const char* czstr) { return write(czstr); }
std::size_t Print::print(char c) { return write(c); }

std::size_t Print::println(const String& s) { return print(s) + println(); }
std::size_t Print::println(const char* czstr) { return write(czstr) + println(); }
std::size_t Print::println(char c) { return write(c) + println(); }

std::size_t Print::println() { return print('\r') + print('\n'); }

void Print::flush() { }
