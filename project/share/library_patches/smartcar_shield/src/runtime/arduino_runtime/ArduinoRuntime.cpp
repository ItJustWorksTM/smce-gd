#include <Arduino.h>
#include "ArduinoRuntime.hpp"

void ArduinoRuntime::setPinDirection(uint8_t pin, uint8_t direction) { pinMode(pin, direction); }

void ArduinoRuntime::setPinState(uint8_t pin, uint8_t state) { digitalWrite(pin, state); }

int ArduinoRuntime::getPinState(uint8_t pin) { return digitalRead(pin); }

int ArduinoRuntime::getAnalogPinState(uint8_t pin) { return analogRead(pin); }

void ArduinoRuntime::setPWM(uint8_t pin, int value) { analogWrite(pin, value); }

void ArduinoRuntime::i2cInit() {}

void ArduinoRuntime::i2cBeginTransmission(uint8_t) {}

size_t ArduinoRuntime::i2cWrite(uint8_t) { return 0; }

uint8_t ArduinoRuntime::i2cEndTransmission() { return true; }

uint8_t ArduinoRuntime::i2cRequestFrom(uint8_t, uint8_t) { return 0; }

int ArduinoRuntime::i2cAvailable() { return 0; }

int ArduinoRuntime::i2cRead() { return 0; }

int8_t ArduinoRuntime::pinToInterrupt(uint8_t pin) { return pin; }

unsigned long ArduinoRuntime::currentTimeMillis() { return millis(); }

unsigned long ArduinoRuntime::currentTimeMicros() { return micros(); }

void ArduinoRuntime::delayMillis(unsigned long milliseconds) { delay(milliseconds); }

void ArduinoRuntime::delayMicros(unsigned int microseconds) { delayMicroseconds(microseconds); }

// unsupported on libSMCE
unsigned long ArduinoRuntime::getPulseDuration(uint8_t, uint8_t, unsigned long) { return 0; }

// unsupported on libSMCE
void ArduinoRuntime::setInterrupt(uint8_t, InterruptCallback, int) {}

uint8_t ArduinoRuntime::getLowState() const { return LOW; }

uint8_t ArduinoRuntime::getHighState() const { return HIGH; }

uint8_t ArduinoRuntime::getOutputState() const { return OUTPUT; }

uint8_t ArduinoRuntime::getInputState() const { return INPUT; }

int ArduinoRuntime::getRisingEdgeMode() const { return -1; } // not supported
