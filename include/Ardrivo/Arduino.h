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

#include <cstdint>

#define PROGMEM

enum {
    LOW,
    HIGH,
};

enum {
    INPUT,
    OUTPUT,
    INPUT_PULLUP = INPUT
};

using boolean = bool;
using byte = std::uint8_t;
using word = std::uint16_t;

void pinMode(int pin, bool mode);

int digitalRead(int pin);
void digitalWrite(int pin, bool value);
void analogWrite(int pin, byte value);
int analogRead(int pin);

void delay(unsigned long long);

void setup(); /// User-defined sketch setup
void loop(); /// User-defined sketch loop

#include "WString.h"
#include "HardwareSerial.h"

#endif // ARDUINO_H
