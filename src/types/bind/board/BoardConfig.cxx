/*
 *  BoardConfig.hxx
 *  Copyright 2021 ItJustWorksTM
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

#include "BoardConfig.hxx"
#include "BoardDeviceSpec.hxx"

using namespace godot;

#define STR(s) #s

void BoardConfig::GpioDriverConfig::_register_methods() {
#define P(f, d) std::tuple{STR(f), &GpioDriverConfig::f, d}
    register_props(P(pin, 0), P(read, true), P(write, true));
    register_method("eq", &GpioDriverConfig::eq);
#undef P
}

smce::BoardConfig::GpioDrivers BoardConfig::GpioDriverConfig::to_native() const {
    return smce::BoardConfig::GpioDrivers{
        .pin_id = static_cast<uint16_t>(pin),
        .digital_driver = smce::BoardConfig::GpioDrivers::DigitalDriver{read, write},
        .analog_driver = smce::BoardConfig::GpioDrivers::AnalogDriver{read, write},
    };
}

void BoardConfig::UartChannelConfig::_register_methods() {
#define P(f, d) std::tuple{STR(f), &UartChannelConfig::f, d}
    register_props(P(rx_pin_override, -1), P(tx_pin_override, -1), P(baud_rate, 9600),
                   P(rx_buffer_length, 64), P(tx_buffer_length, 64), P(flushing_threshold, 0));
#undef P
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

void BoardConfig::FrameBufferConfig::_register_methods() {
    register_property("key", &FrameBufferConfig::key, 0);
    register_property("direction", &FrameBufferConfig::direction, true);
    register_method("eq", &FrameBufferConfig::eq);
}

smce::BoardConfig::FrameBuffer BoardConfig::FrameBufferConfig::to_native() const {
    using Direction = smce::BoardConfig::FrameBuffer::Direction;
    return {.key = static_cast<size_t>(key), .direction = direction ? Direction::in : Direction::out};
}

void BoardConfig::SecureDigitalStorage::_register_methods() {
    register_property("cspin", &SecureDigitalStorage::cspin, 0);
    register_property("root_dir", &SecureDigitalStorage::root_dir, String{});
    register_method("eq", &SecureDigitalStorage::eq);
}

smce::BoardConfig::SecureDigitalStorage BoardConfig::SecureDigitalStorage::to_native() const {
    return {.cspin = static_cast<uint16_t>(cspin), .root_dir = std_str(root_dir)};
}

void BoardConfig::BoardDeviceConfig::_register_methods() {
    register_method("with_spec", &BoardDeviceConfig::with_spec);
    register_property("spec", &BoardConfig::BoardDeviceConfig::spec, {});
    register_property("amount", &BoardConfig::BoardDeviceConfig::amount, size_t{1});
}

smce::BoardConfig::BoardDevice BoardConfig::BoardDeviceConfig::to_native() {
    return {.spec = std::cref(spec->to_native()), .count = amount};
}

void BoardConfig::_register_methods() {
    register_property("gpio_drivers", &BoardConfig::gpio_drivers, Array{});
    register_property("uart_channels", &BoardConfig::uart_channels, Array{});
    register_property("frame_buffers", &BoardConfig::frame_buffers, Array{});
    register_property("sd_cards", &BoardConfig::sd_cards, Array{});
    register_property("board_devices", &BoardConfig::board_devices, Array{});
}

smce::BoardConfig BoardConfig::to_native() const {
    auto rep = []<class T>(auto& arr, auto& out) {
        for (size_t i = 0; i < arr.size(); ++i)
            if (const auto obj = Object::cast_to<T>(arr[i]))
                out.push_back(obj->to_native());
    };

    auto ret = smce::BoardConfig{};
    rep.operator()<GpioDriverConfig>(gpio_drivers, ret.gpio_drivers);
    rep.operator()<UartChannelConfig>(uart_channels, ret.uart_channels);
    rep.operator()<FrameBufferConfig>(frame_buffers, ret.frame_buffers);
    rep.operator()<SecureDigitalStorage>(sd_cards, ret.sd_cards);
    rep.operator()<BoardDeviceConfig>(board_devices, ret.board_devices);

    for (const auto& driver : ret.gpio_drivers)
        ret.pins.push_back(driver.pin_id);

    return ret;
}
