#include "GP2Y0A21.hpp"

GP2Y0A21::GP2Y0A21(Runtime& runtime, uint8_t pin)
    : InfraredAnalogSensor(runtime), kPin{pin}, mRuntime(runtime) {
    runtime.setPinDirection(pin, runtime.getInputState());
}

unsigned int GP2Y0A21::getDistance() {
    return mRuntime.getAnalogPinState(kPin);
}
