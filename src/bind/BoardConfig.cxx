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

#include "bind/BoardConfig.hxx"

using namespace godot;

void GpioDriver::_register_methods() {
    register_property("type", &GpioDriver::type, {}, GODOT_METHOD_RPC_MODE_DISABLED,
                      GODOT_PROPERTY_USAGE_DEFAULT, GODOT_PROPERTY_HINT_ENUM, "Analog, Digital, Both");
    register_property("pin", &GpioDriver::pin, {});
    register_property("allow_read", &GpioDriver::allow_read, true);
    register_property("allow_write", &GpioDriver::allow_write, true);
}

smce::BoardConfig::GpioDrivers GpioDriver::to_native() {
    auto ret = smce::BoardConfig::GpioDrivers{.pin_id = pin};

    if (type == 0 || type == 3)
        ret.analog_driver = {{.board_read = allow_read, .board_write = allow_write}};
    if (type == 1 || type == 3)
        ret.digital_driver = {{.board_read = allow_read, .board_write = allow_write}};

    return ret;
}

void GpioDriverGroup::_register_methods() {
    register_property("gpio_drivers", &GpioDriverGroup::set_arr, &GpioDriverGroup::get_arr, {});
}

std::vector<smce::BoardConfig::GpioDrivers> GpioDriverGroup::to_native() {
    auto ret = std::vector<smce::BoardConfig::GpioDrivers>{};
    for (size_t i = 0; i < gpio_drivers.size(); ++i)
        if (auto driver = Object::cast_to<GpioDriver>(gpio_drivers[i]))
            ret.push_back(driver->to_native());
    return ret;
}

void GpioDriverGroup::set_arr(Array arr) {
    gpio_drivers = arr;
    for (size_t i = 0; i < gpio_drivers.size(); ++i)
        if (Object::cast_to<GpioDriver>(gpio_drivers[i]) == nullptr)
            gpio_drivers[i] = GpioDriver::_new();
}

Array GpioDriverGroup::get_arr() { return gpio_drivers; }

void BoardConfig::_register_methods() {
    register_property("uart_channels", &BoardConfig::uart_channels, 0);
    register_property("gpio_drivers", &BoardConfig::set_arr, &BoardConfig::get_arr, {});
}

Array BoardConfig::get_arr() { return gpio_drivers; }

void BoardConfig::set_arr(Array arr) {
    gpio_drivers = arr;
    for (size_t i = 0; i < gpio_drivers.size(); ++i)
        if (Object::cast_to<GpioDriverGroup>(gpio_drivers[i]) == nullptr)
            gpio_drivers[i] = GpioDriverGroup::_new();
}

smce::BoardConfig BoardConfig::to_native() {
    auto ret = smce::BoardConfig{};

    for (size_t i = 0; i < gpio_drivers.size(); ++i)
        if (auto driver = Object::cast_to<GpioDriverGroup>(gpio_drivers[i])) {
            const auto native = driver->to_native();
            ret.gpio_drivers.insert(ret.gpio_drivers.end(), native.begin(), native.end());
        }

    for (const auto& driver : ret.gpio_drivers)
        ret.pins.push_back(driver.pin_id);

    for (size_t i = 0; i < uart_channels; ++i)
        ret.uart_channels.emplace_back();
    return ret;
}
