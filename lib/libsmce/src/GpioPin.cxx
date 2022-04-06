#include "SMCE_gd/GpioPin.hxx"
#include "SMCE_gd/utility.hxx"
#include "godot_cpp/variant/utility_functions.hpp"

using namespace godot;

void GpioPin::_bind_methods() {
    bind_method("analog_read", &This::analog_read);
    bind_method("analog_write", &This::analog_write);
    bind_method("digital_read", &This::digital_read);
    bind_method("digital_write", &This::digital_write);
}

Ref<GpioPin> GpioPin::from_native(smce::VirtualPin pin) {
    if (!pin.exists()) {
        UtilityFunctions::print("CANT WRITE TO THIS PIN!");
    }
    auto ret = make_ref<This>();
    ret->vpin = pin;
    return ret;
}

int GpioPin::analog_read() { return vpin.analog().read(); }
void GpioPin::analog_write(int value) {
    auto exitst = vpin.analog().exists();
    auto write = vpin.analog().can_write();

    vpin.analog().write(static_cast<uint16_t>(value));
}

bool GpioPin::digital_read() { return vpin.digital().read(); }
void GpioPin::digital_write(bool value) { return vpin.digital().write(value); }
