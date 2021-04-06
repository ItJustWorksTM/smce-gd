#pragma once

#include "DirectionlessOdometer.hpp"

struct DirectionalOdometerPins {
    DirectionalOdometerPins(uint8_t pulsePin, uint8_t forwardWhenLowPin)
        : pulse{pulsePin}, direction{forwardWhenLowPin} {}

    const uint8_t pulse;
    const uint8_t direction;
};

class DirectionalOdometer : public DirectionlessOdometer {
    uint8_t direction_pin;

  public:
    DirectionalOdometer(Runtime& runtime, uint8_t pulsePin, uint8_t forwardWhenLowPin,
                        InterruptCallback callback, unsigned long pulsesPerMeter)
        : DirectionlessOdometer{runtime, pulsePin, callback, pulsesPerMeter}, direction_pin{
                                                                                  forwardWhenLowPin} {}

    DirectionalOdometer(Runtime& runtime, DirectionalOdometerPins pins, InterruptCallback callback,
                        unsigned long pulsesPerMeter)
        : DirectionalOdometer(runtime, pins.pulse, pins.direction, callback, pulsesPerMeter) {}

    long getDistance() override {
        return (runtime.getAnalogPinState(fwd_dist_pin) - runtime.getAnalogPinState(bwd_dist_pin)) / 10;
    }

    bool providesDirection() const override { return true; }

    int8_t getDirection() const {
        return runtime.getPinState(direction_pin) ? smartcarlib::constants::odometer::kForward
                                                  : smartcarlib::constants::odometer::kBackward;
    }
};
