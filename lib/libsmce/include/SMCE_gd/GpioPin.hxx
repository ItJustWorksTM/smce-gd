
#ifndef SMCE_GD_GPIOPIN_HXX
#define SMCE_GD_GPIOPIN_HXX

#include <SMCE/BoardView.hpp>
#include "SMCE_gd/BoardConfig.hxx"
#include "SMCE_gd/gd_class.hxx"
#include "godot_cpp/godot.hpp"

class GpioPin : public GdRef<"GpioPin", GpioPin> {

    smce::VirtualPin vpin = smce::BoardView{}.pins[0];

    Ref<BoardConfig::GpioDriverConfig> m_info;

  public:
    static void _bind_methods();

    static Ref<GpioPin> from_native(Ref<BoardConfig::GpioDriverConfig> info, smce::VirtualPin pin);

    int analog_read();
    void analog_write(int value);

    bool digital_read();
    void digital_write(bool value);

    Ref<BoardConfig::GpioDriverConfig> info();
};

#endif