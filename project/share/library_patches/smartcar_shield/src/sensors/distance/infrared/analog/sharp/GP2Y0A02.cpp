#include "GP2Y0A02.hpp"

GP2Y0A02::GP2Y0A02(Runtime& runtime, uint8_t pin)
    : InfraredAnalogSensor(runtime), kPin{pin}, mRuntime(runtime) {
    runtime.setPinDirection(pin, runtime.getInputState());
}

unsigned int GP2Y0A02::getDistance() {
    return mRuntime.getAnalogPinState(kPin);
}
