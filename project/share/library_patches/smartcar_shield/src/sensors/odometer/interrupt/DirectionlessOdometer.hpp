#pragma once

#include <stdint.h>

#include "../../../runtime/Runtime.hpp"
#include "../Odometer.hpp"

class DirectionlessOdometer : public Odometer {
  protected:
    constexpr static uint8_t magic_offset = 50;
    Runtime& runtime;
    uint8_t fwd_dist_pin;
    uint8_t bwd_dist_pin;
    uint8_t speed_pin;

  public:
    DirectionlessOdometer(Runtime& runtime, uint8_t pulsePin, InterruptCallback callback,
                          unsigned long pulsesPerMeter)
        : runtime{runtime}, fwd_dist_pin{pulsePin},
          bwd_dist_pin{static_cast<uint8_t>(pulsePin + magic_offset * 2)}, speed_pin{static_cast<uint8_t>(
                                                                               pulsePin + magic_offset)} {
        runtime.setPinDirection(fwd_dist_pin, runtime.getInputState());
        runtime.setPinDirection(speed_pin, runtime.getInputState());
        runtime.setPinDirection(bwd_dist_pin, runtime.getInputState());
    }
    ~DirectionlessOdometer() override = default;

    long getDistance() override {
        return runtime.getAnalogPinState(fwd_dist_pin) + runtime.getAnalogPinState(bwd_dist_pin);
    }

    float getSpeed() override { return runtime.getAnalogPinState(speed_pin) / 1000.0; }

    bool isAttached() const override { return true; }
    bool providesDirection() const override { return false; }

    virtual void reset() {
        runtime.setPinDirection(fwd_dist_pin, runtime.getOutputState());
        runtime.setPWM(fwd_dist_pin, 0);
        runtime.setPinDirection(fwd_dist_pin, runtime.getInputState());

        runtime.setPinDirection(bwd_dist_pin, runtime.getOutputState());
        runtime.setPWM(bwd_dist_pin, 0);
        runtime.setPinDirection(bwd_dist_pin, runtime.getInputState());
    }

    virtual void update() {}
};
