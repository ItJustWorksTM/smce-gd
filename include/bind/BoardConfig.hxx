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
#include <tuple>
#include <SMCE/BoardConf.hpp>
#include <SMCE/BoardView.hpp>
#include <core/Godot.hpp>
#include <gen/Node.hpp>
#include <gen/Resource.hpp>
#include "gd/util.hxx"

namespace godot {

class BoardConfig : public Reference {
    GODOT_CLASS(BoardConfig, Reference);

  public:
    class GpioDriverConfig : public Reference {
        GODOT_CLASS(GpioDriverConfig, Reference);

      public:
        int pin = 0;
        bool analog = false;
        bool analog_read = true;
        bool analog_write = true;
        bool digital = false;
        bool digital_read = true;
        bool digital_write = true;

        static void _register_methods();

        void _init() {}

        smce::BoardConfig::GpioDrivers to_native() const;
    };

    class UartChannelConfig : public Reference {
        GODOT_CLASS(UartChannelConfig, Reference)
      public:
        int rx_pin_override = -1;
        int tx_pin_override = -1;
        int baud_rate = 9600;
        int rx_buffer_length = 64;
        int tx_buffer_length = 64;
        int flushing_threshold = 0;

        static void _register_methods();

        void _init() {}

        smce::BoardConfig::UartChannel to_native() const;
    };

    class FrameBufferConfig : public Reference {
        GODOT_CLASS(FrameBufferConfig, Reference)

      public:
        int key = 0;
        bool direction = true; // true = in, false = out

        static void _register_methods();

        void _init() {}

        smce::BoardConfig::FrameBuffer to_native() const;
    };

    Array gpio_drivers;
    Array uart_channels;
    Array frame_buffers;

    static void _register_methods();
    void _init() {}

    Dictionary type_info();

    smce::BoardConfig to_native() const;
};

} // namespace godot

#endif // GODOT_SMCE_BOARDCONFIG_HXX
