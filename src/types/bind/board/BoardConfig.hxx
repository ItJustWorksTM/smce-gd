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
#include "types/bind/board/BoardDeviceSpec.hxx"
#include "util/Extensions.hxx"

namespace godot {

struct BoardConfig : public GdRef<"BoardConfig", BoardConfig> {

  public:
    struct GpioDriverConfig : public GdRef<"GpioDriverConfig", GpioDriverConfig> {
        int pin = 0;
        bool read = true;
        bool write = true;

        static void _register_methods();

        bool eq(Ref<GpioDriverConfig> rhs) { return rhs->pin == pin; }

        smce::BoardConfig::GpioDrivers to_native() const;
    };

    struct UartChannelConfig : public GdRef<"UartChannelConfig", UartChannelConfig> {
        int rx_pin_override = -1;
        int tx_pin_override = -1;
        int baud_rate = 9600;
        int rx_buffer_length = 64;
        int tx_buffer_length = 64;
        int flushing_threshold = 0;

        static void _register_methods();

        smce::BoardConfig::UartChannel to_native() const;
    };

    struct FrameBufferConfig : public GdRef<"FrameBufferConfig", FrameBufferConfig> {
        int key = 0;
        bool direction = true; // true = in, false = out

        static void _register_methods();

        bool eq(Ref<FrameBufferConfig> rhs) { return rhs->key == key; }

        smce::BoardConfig::FrameBuffer to_native() const;
    };

    struct SecureDigitalStorage : public GdRef<"SecureDigitalStorage", SecureDigitalStorage> {
        int cspin;
        String root_dir;

        static void _register_methods();

        bool eq(Ref<SecureDigitalStorage> rhs) { return rhs->cspin == cspin; }

        smce::BoardConfig::SecureDigitalStorage to_native() const;
    };

    struct BoardDeviceConfig : public GdRef<"BoardDeviceConfig", BoardDeviceConfig> {
        Ref<BoardDeviceSpec> spec;
        size_t amount = 1;

        static void _register_methods();

        Ref<BoardDeviceConfig> with_spec(Ref<BoardDeviceSpec> s) {
            spec = s;
            return this;
        };

        smce::BoardConfig::BoardDevice to_native();
    };

    Array gpio_drivers;
    Array uart_channels;
    Array frame_buffers;
    Array sd_cards;
    Array board_devices;

    static void _register_methods();

    smce::BoardConfig to_native() const;
};

} // namespace godot

#endif // GODOT_SMCE_BOARDCONFIG_HXX
