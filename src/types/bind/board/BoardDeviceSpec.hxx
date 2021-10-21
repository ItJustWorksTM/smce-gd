/*
 *  BoardDeviceSpec.hxx
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

#ifndef GODOT_SMCE_BOARDDEVICESPEC_HXX
#define GODOT_SMCE_BOARDDEVICESPEC_HXX

#include <string>
#include <vector>
#include <SMCE/internal/BoardDeviceSpecification.hpp>
#include "gen/Reference.hpp"
#include "Godot.hpp"

namespace godot {

class DynamicBoardDevice;
// TODO: check for duplicate fields!
class BoardDeviceSpec : public Reference {
    GODOT_CLASS(BoardDeviceSpec, Reference);

    friend DynamicBoardDevice;

    smce::BoardDeviceSpecification spec{};

    std::string m_full{};
    std::string std_name;

  public:
    String name;
    String version = "1.0";
    Array /* String */ a8_fields;
    Array /* String */ a16_fields;
    Array /* String */ a32_fields;
    Array /* String */ mtx_fields;

    void _init() {}

    static void _register_methods();

    BoardDeviceSpec* with_name(String type_name);
    BoardDeviceSpec* with_mutex(String field_name);
    BoardDeviceSpec* with_atomic_u8(String field_name);
    BoardDeviceSpec* with_atomic_u32(String field_name);

    std::string to_full_string();

    const smce::BoardDeviceSpecification& to_native();

    String _to_string() { return String{to_full_string().data()}; }

    // Name HAS to be unique
    bool eq(Ref<BoardDeviceSpec> rhs) { return rhs->name == name; }
};
} // namespace godot

#endif // GODOT_SMCE_BOARDDEVICESPEC_HXX
