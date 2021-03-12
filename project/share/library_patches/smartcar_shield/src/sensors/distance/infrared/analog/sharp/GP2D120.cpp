#include "GP2D120.hpp"

GP2D120::GP2D120(Runtime& runtime, uint8_t pin)
    : InfraredAnalogSensor(runtime), kPin{pin}, mRuntime(runtime) {
    runtime.setPinDirection(pin, runtime.getInputState());
}

unsigned int GP2D120::getDistance() {
    return mRuntime.getAnalogPinState(kPin);
}
