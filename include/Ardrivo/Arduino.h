/*
 *  Arduino.h
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

#ifndef ARDUINO_H
#define ARDUINO_H

#include <algorithm>
#include <cctype>
#include <cmath>
#include <cstdint>
#include <cstdlib>
#include "SMCE_dll.hpp"

#define PROGMEM
#define F(str) str

// clang-format off
enum {
    LOW,
    HIGH,
};

enum {
    INPUT,
    OUTPUT,
    INPUT_PULLUP = INPUT
};
// clang-format on

using boolean = bool;
using byte = std::uint8_t;
using word = std::uint16_t;

SMCE__DLL_RT_API void pinMode(int pin, bool mode);

//** Digital I/O **//
SMCE__DLL_RT_API int digitalRead(int pin);
SMCE__DLL_RT_API void digitalWrite(int pin, bool value);

//** Analog I/O **//
SMCE__DLL_RT_API void analogWrite(int pin, byte value);
SMCE__DLL_RT_API int analogRead(int pin);

//** Time **//
SMCE__DLL_RT_API void delay(unsigned long long);
SMCE__DLL_RT_API void delayMicroseconds(unsigned long long);
SMCE__DLL_RT_API unsigned long micros();
SMCE__DLL_RT_API unsigned long millis();

//** Math **//
using std::abs;
// Straight from https://www.arduino.cc/reference/en/language/functions/math/map/#Appendix
inline long map(long x, long in_min, long in_max, long out_min, long out_max) {
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}
using std::max;
using std::min;
using std::pow;
template <class T>
T sq(T x) {
    return x * x;
}
using std::sqrt;

//** Trigonometry **//
using std::cos;
using std::sin;
using std::tan;

//** Characters **//
inline bool isAlpha(char c) noexcept { return std::isalpha(+c); }
inline bool isAlphaNumeric(char c) noexcept { return std::isalnum(+c); }
inline bool isAscii(char c) noexcept { return static_cast<signed char>(c) >= 0; }
inline bool isControl(char c) noexcept { return std::iscntrl(+c); }
inline bool isDigit(char c) noexcept { return std::isdigit(+c); }
inline bool isGraph(char c) noexcept { return std::isgraph(+c); }
inline bool isHexadecimalDigit(char c) noexcept { return std::isxdigit(+c); }
inline bool isLowerCase(char c) noexcept { return std::islower(+c); }
inline bool isPrintable(char c) noexcept { return std::isprint(+c); }
inline bool isPunct(char c) noexcept { return std::ispunct(+c); }
inline bool isSpace(char c) noexcept { return std::isspace(+c); }
inline bool isUpperCase(char c) noexcept { return std::isupper(+c); }
inline bool isWhitespace(char c) noexcept { return c == ' ' || c == '\t'; }

//** Random numbers **//
inline long random(long min, long max) { return std::rand() % (max - min) + min; }
inline long random(long max) { return random(0, max); }
inline void randomSeed(unsigned long s) { std::srand(s); }

//** Bits **//
#define bit(n) (1 << (n))
#define bitClear(x, n) ((x) & ~bitn(n))
#define bitRead(x, n) (((x) >> (n)) & 1)
#define bitSet(x, n) ((x) | bitn(n))
#define bitWrite(x, n, b) ((x) ^ ((-(v) ^ (x)) & (1 << (n))))
#define highByte(x) lowByte((x) >> 8)
#define lowByte(x) (((x)) & 0xFF)

void setup(); /// User-defined sketch setup
void loop();  /// User-defined sketch loop

#include "HardwareSerial.h"
#include "WString.h"

#endif // ARDUINO_H
