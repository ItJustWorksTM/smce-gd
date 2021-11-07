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

#include "util/Extensions.hxx"
#include "BoardDeviceSpec.hxx"

using namespace godot;

void BoardDeviceSpec::_register_methods() {
    register_method("with_mutex", &BoardDeviceSpec::with_mutex);
    register_method("with_atomic_u8", &BoardDeviceSpec::with_atomic_u8);
    register_method("with_name", &BoardDeviceSpec::with_name);
    register_method("with_atomic_u32", &BoardDeviceSpec::with_atomic_u32);
    register_method("_to_string", &BoardDeviceSpec::_to_string);
    register_method("eq", &BoardDeviceSpec::eq);
    register_property("name", &BoardDeviceSpec::name, String{});
    register_property("version", &BoardDeviceSpec::name, String{});
    register_property("a8_fields", &BoardDeviceSpec::a8_fields, Array{});
    register_property("a16_fields", &BoardDeviceSpec::a16_fields, Array{});
    register_property("a32_fields", &BoardDeviceSpec::a32_fields, Array{});
    register_property("mtx_fields", &BoardDeviceSpec::mtx_fields, Array{});
}

BoardDeviceSpec* BoardDeviceSpec::with_name(String type_name) {
    name = type_name;
    std_name = std_str(type_name);
    return this;
}

BoardDeviceSpec* BoardDeviceSpec::with_mutex(String field_name) {
    mtx_fields.push_back(field_name);
    return this;
}

BoardDeviceSpec* BoardDeviceSpec::with_atomic_u8(String field_name) {
    a8_fields.push_back(field_name);
    return this;
}

BoardDeviceSpec* BoardDeviceSpec::with_atomic_u32(String field_name) {
    a32_fields.push_back(field_name);
    return this;
}

std::string BoardDeviceSpec::to_full_string() {
    std::string full_string{};

    full_string += "\"" + std_str(name) + "\" ";
    full_string += "\"" + std_str(version) + "\" ";

    auto apply_fields = [&](const std::string& prefix, const auto& vec) {
        for (size_t i = 0; i < vec.size(); ++i) {
            full_string += "\"" + prefix + " " + std_str(vec[i]) + "\" ";
        }
    };

    apply_fields("au8", a8_fields);
    apply_fields("au16", a16_fields);
    apply_fields("au32", a32_fields);
    apply_fields("mutex", mtx_fields);

    return full_string;
}

const smce::BoardDeviceSpecification& BoardDeviceSpec::to_native() {

    m_full = to_full_string();

    spec = smce::BoardDeviceSpecification{
        {m_full},
        {std_name},
        0,
        0,
        0,
        0,
        static_cast<size_t>(a8_fields.size()),
        static_cast<size_t>(a16_fields.size()),
        static_cast<size_t>(a32_fields.size()),
        0,
        static_cast<size_t>(mtx_fields.size()),
    };

    return spec;
}