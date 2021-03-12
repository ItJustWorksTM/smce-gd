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

#ifndef GODOT_SMCE_BOARDCONFIG_HXX
#define GODOT_SMCE_BOARDCONFIG_HXX

#include <functional>
#include <SMCE/BoardConf.hpp>
#include <SMCE/BoardView.hpp>
#include <core/Godot.hpp>
#include <gen/Node.hpp>
#include <gen/Resource.hpp>
#include "gd/util.hxx"

namespace godot {

class GpioDriver : public Resource {
    GODOT_CLASS(GpioDriver, Resource)

  public:
    uint16_t pin;
    int type;
    bool allow_read = true;
    bool allow_write = true;

    static void _register_methods();

    void _init() {}

    smce::BoardConfig::GpioDrivers to_native();
};

class GpioDriverGroup : public Resource {
    GODOT_CLASS(GpioDriverGroup, Resource)

  public:
    Array gpio_drivers;

    static void _register_methods();

    void _init() {}

    Array get_arr();
    void set_arr(Array arr);

    std::vector<smce::BoardConfig::GpioDrivers> to_native();
};

class BoardConfig : public Resource {
    GODOT_CLASS(BoardConfig, Resource)

  public:
    Array gpio_drivers;
    int uart_channels = 0;

    static void _register_methods();

    void _init() {}

    Array get_arr();
    void set_arr(Array arr);

    smce::BoardConfig to_native();
};
} // namespace godot

#endif // GODOT_SMCE_BOARDCONFIG_HXX
