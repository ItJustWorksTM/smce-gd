#include "../../../utilities/Utilities.hpp"
#include "GY50.hpp"

// Since we dont have i2c we just make one up
constexpr uint8_t gyro_pin = 205;

using namespace smartcarlib::utils;
using namespace smartcarlib::constants::gy50;

GY50::GY50(Runtime& runtime, int offset, unsigned long samplingInterval)
    : kOffset{offset}, kSamplingInterval{samplingInterval}, mRuntime{runtime},
      mPreviousSample{0}, mAttached{false}, mAngularDisplacement{0} {
    attach();
    // unused
    static_cast<void>(kOffset);
    static_cast<void>(kSamplingInterval);
    static_cast<void>(mPreviousSample);
}

int GY50::getHeading() { return static_cast<int>(mAngularDisplacement); }

void GY50::update() { mAngularDisplacement = static_cast<float>(mRuntime.getAnalogPinState(gyro_pin)); }

void GY50::attach() {
    mRuntime.setPinDirection(gyro_pin, mRuntime.getInputState());
    mAttached = true;
}

int GY50::getOffset(int) { return 0; } // for now we are perfect

int GY50::getAngularVelocity() { return 0; }
int GY50::readL3G4200DRegister(uint8_t) { return 0; }
void GY50::writeL3G4200DRegister(uint8_t, uint8_t) {}
