/*
 *  GpioPin.hxx
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

#include <SMCE/BoardView.hpp>
#include "core/Godot.hpp"

namespace godot {
class GpioPin : public Reference {
    GODOT_CLASS(GpioPin, Reference)

    smce::VirtualPin vpin = smce::BoardView{}.pins[0];

    Ref<BoardConfig::GpioDriverConfig> m_info;

  public:
    void _init() {}
    static void _register_methods();

    static Ref<GpioPin> from_native(Ref<BoardConfig::GpioDriverConfig> info, smce::VirtualPin pin);

    int analog_read();
    void analog_write(int value);

    bool digital_read();
    void digital_write(bool value);

    Ref<BoardConfig::GpioDriverConfig> info();
};
} // namespace godot
