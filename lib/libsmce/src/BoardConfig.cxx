#include "SMCE_gd/BoardConfig.hxx"

smce::BoardConfig::GpioDrivers BoardConfig::GpioDriverConfig::to_native() const {
    return smce::BoardConfig::GpioDrivers{
        .pin_id = static_cast<uint16_t>(pin),
        .digital_driver = smce::BoardConfig::GpioDrivers::DigitalDriver{read, write},
        .analog_driver = smce::BoardConfig::GpioDrivers::AnalogDriver{read, write},
    };
}

void BoardConfig::GpioDriverConfig::_bind_methods() {
    bind_prop_rw<"pin", Variant::Type::INT, &This::pin>();
    bind_prop_rw<"read", Variant::Type::BOOL, &This::read>();
    bind_prop_rw<"write", Variant::Type::BOOL, &This::write>();
}

smce::BoardConfig::SecureDigitalStorage BoardConfig::SecureDigitalStorageConfig::to_native() const {
    return {.cspin = static_cast<uint16_t>(cspin), .root_dir = as_view(root_dir)};
}

void BoardConfig::SecureDigitalStorageConfig::_bind_methods() {
    bind_prop_rw<"cspin", Variant::Type::INT, &This::cspin>();
    bind_prop_rw<"root_dir", Variant::Type::STRING, &This::root_dir>();
}

smce::BoardConfig::UartChannel BoardConfig::UartChannelConfig::to_native() const {
    auto ret = smce::BoardConfig::UartChannel{std::nullopt,
                                              std::nullopt,
                                              static_cast<uint16_t>(baud_rate),
                                              static_cast<size_t>(rx_buffer_length),
                                              static_cast<size_t>(tx_buffer_length),
                                              static_cast<size_t>(flushing_threshold)};
    if (rx_pin_override >= 0)
        ret.rx_pin_override = rx_pin_override;
    if (tx_pin_override >= 0)
        ret.tx_pin_override = tx_pin_override;
    return ret;
}

void BoardConfig::UartChannelConfig::_bind_methods() {
    bind_prop_rw<"rx_pin_override", Variant::Type::INT, &This::rx_pin_override>();
    bind_prop_rw<"tx_pin_override", Variant::Type::INT, &This::tx_pin_override>();
    bind_prop_rw<"baud_rate", Variant::Type::INT, &This::baud_rate>();
    bind_prop_rw<"rx_buffer_length", Variant::Type::INT, &This::rx_buffer_length>();
    bind_prop_rw<"tx_buffer_length", Variant::Type::INT, &This::tx_buffer_length>();
    bind_prop_rw<"flushing_threshold", Variant::Type::INT, &This::flushing_threshold>();
}

smce::BoardConfig::FrameBuffer BoardConfig::FrameBufferConfig::to_native() const {
    using Direction = smce::BoardConfig::FrameBuffer::Direction;
    return {.key = static_cast<size_t>(key), .direction = direction ? Direction::in : Direction::out};
}

void BoardConfig::FrameBufferConfig::_bind_methods() {
    bind_enum("Direction", std::array{"DIRECTION_IN", "DIRECTION_OUT"});
    bind_prop_rw<"key", Variant::Type::INT, &This::key>();
    bind_prop_rw<"direction", Variant::Type::INT, &This::direction>();
}

void BoardConfig::BoardDeviceConfig::_bind_methods() {
    bind_prop_rw<"device_name", Variant::Type::STRING, &This::device_name>();
    bind_prop_rw<"version", Variant::Type::STRING, &This::version>();
    bind_prop_rw<"count", Variant::Type::INT, &This::count>();
}

smce::BoardConfig BoardConfig::resolve_native(Ref<ManifestRegistry> registry) const {
    auto rep = []<class T>(auto& arr, auto& out) {
        for (size_t i = 0; i < arr.size(); ++i)
            if (const auto obj = Object::cast_to<T>(arr[i]))
                out.push_back(obj->to_native());
    };

    auto ret = smce::BoardConfig{};
    rep.operator()<GpioDriverConfig>(gpio_drivers, ret.gpio_drivers);
    rep.operator()<UartChannelConfig>(uart_channels, ret.uart_channels);
    rep.operator()<FrameBufferConfig>(frame_buffers, ret.frame_buffers);
    rep.operator()<SecureDigitalStorageConfig>(sd_cards, ret.sd_cards);
    // rep.operator()<BoardDeviceConfig>(board_devices, ret.board_devices);

    for (const auto& driver : ret.gpio_drivers)
        ret.pins.push_back(driver.pin_id);

    return ret;
}

void BoardConfig::_bind_methods() {
    bind_prop_rw<"pins", Variant::Type::PACKED_INT32_ARRAY, &This::pins>();
    bind_prop_rw<"gpio_drivers", Variant::Type::ARRAY, &This::gpio_drivers>();
    bind_prop_rw<"uart_channels", Variant::Type::ARRAY, &This::uart_channels>();
    bind_prop_rw<"sd_cards", Variant::Type::ARRAY, &This::sd_cards>();
    bind_prop_rw<"frame_buffers", Variant::Type::ARRAY, &This::frame_buffers>();
    bind_prop_rw<"board_devices", Variant::Type::ARRAY, &This::board_devices>();
}