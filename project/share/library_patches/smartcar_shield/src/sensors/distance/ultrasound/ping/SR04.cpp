#include "../../../../utilities/Utilities.hpp"
#include "SR04.hpp"

const unsigned long kMedianMeasurementDelay = 15;

using namespace smartcarlib::constants::sr04;
using namespace smartcarlib::constants::distanceSensor;
using namespace smartcarlib::utils;

SR04::SR04(Runtime& runtime, uint8_t triggerPin, uint8_t echoPin, unsigned int maxDistance)
    : kTriggerPin{triggerPin}, kEchoPin{echoPin},
      kMaxDistance{maxDistance > 0 ? maxDistance : kDefaultMaxDistance}, kTimeout{},
      mRuntime(runtime), kOutput{}, kInput{}, kLow{}, kHigh{} {
    mRuntime.setPinDirection(kEchoPin, mRuntime.getInputState());
    mAttached = true;
    // Unused
    static_cast<void>(kTriggerPin);
    static_cast<void>(kTimeout);
    static_cast<void>(kOutput);
    static_cast<void>(kInput);
    static_cast<void>(kLow);
    static_cast<void>(kHigh);
}

void SR04::attach() {}

unsigned int SR04::getDistance() {
    const unsigned calculatedDistance = mRuntime.getAnalogPinState(kEchoPin);
    return calculatedDistance <= kMaxDistance ? calculatedDistance : kError;
}

unsigned int SR04::getMedianDistance(uint8_t iterations) {
    if (iterations == 0 || iterations > kMaxMedianMeasurements) {
        return kError;
    }

    unsigned int measurements[kMaxMedianMeasurements];
    for (auto i = 0; i < iterations; i++) {
        measurements[i] = getDistance();
        mRuntime.delayMillis(kMedianMeasurementDelay);
    }

    return getMedian(measurements, iterations);
}
