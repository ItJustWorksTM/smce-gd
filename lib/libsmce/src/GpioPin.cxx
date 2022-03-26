#include "SMCE_gd/GpioPin.hxx"
#include "SMCE_gd/utility.hxx"

using namespace godot;

void GpioPin::_bind_methods() {
    bind_method("analog_read", &This::analog_read);
    bind_method("analog_write", &This::analog_write);
    bind_method("digital_read", &This::digital_read);
    bind_method("digital_write", &This::digital_write);
    bind_method("info", &This::info);
}

Ref<GpioPin> GpioPin::from_native(Ref<BoardConfig::GpioDriverConfig> info, smce::VirtualPin pin) {
    auto ret = make_ref<This>();
    ret->vpin = pin;
    ret->m_info = info;
    return ret;
}

int GpioPin::analog_read() { return vpin.analog().read(); }
void GpioPin::analog_write(int value) { vpin.analog().write(static_cast<uint16_t>(value)); }

bool GpioPin::digital_read() { return vpin.digital().read(); }
void GpioPin::digital_write(bool value) { return vpin.digital().write(value); }

Ref<BoardConfig::GpioDriverConfig> GpioPin::info() { return m_info; }