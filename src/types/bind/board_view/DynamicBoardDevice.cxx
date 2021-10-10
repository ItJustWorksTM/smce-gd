/*
 *  DynamicBoardDevice.cxx
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

#include "DynamicBoardDevice.hxx"

using namespace godot;

void DynamicBoardDevice::_register_methods() {
    register_method("_get", &DynamicBoardDevice::_get);
    register_method("_set", &DynamicBoardDevice::_set);
    register_method("info", &DynamicBoardDevice::info);
}

Ref<DynamicBoardDevice> DynamicBoardDevice::create(Ref<BoardDeviceSpec> spec, smce::BoardView& bv) {
    auto ret = make_ref<DynamicBoardDevice>();

    auto native = spec->to_native();

    auto bases = smce_rt::getBases(bv, native.name);

    const auto make_prop = [&](auto&& value, const auto& field, auto offset_size, auto** base_ptr) {
        value.assign(smce_rt::Impl{}, *base_ptr);
        *base_ptr = static_cast<char*>(*base_ptr) + offset_size;
        ret->properties.insert(std::pair{static_cast<String>(field), std::move(PropType{std::move(value)})});
    };

    for (size_t i = 0; i < native.a8_count; ++i) {
        make_prop(smce_rt::AtomicU8{}, spec->a8_fields[i], smce_rt::A8_size, &bases.a8);
    }

    for (size_t i = 0; i < native.a16_count; ++i) {
        make_prop(smce_rt::AtomicU8{}, spec->a16_fields[i], smce_rt::A16_size, &bases.a16);
    }

    for (size_t i = 0; i < native.a32_count; ++i) {
        make_prop(smce_rt::AtomicU32{}, spec->a32_fields[i], smce_rt::A32_size, &bases.a32);
    }

    for (size_t i = 0; i < native.mtx_count; ++i) {
        auto gdmtx = make_ref<BoardDeviceMutex>();
        gdmtx->mtx.assign(smce_rt::Impl{}, bases.mtx);
        bases.mtx = static_cast<char*>(bases.mtx) + smce_rt::Mtx_size;
        ret->properties.insert(
            std::pair{static_cast<String>(spec->mtx_fields[i]), std::move(PropType{gdmtx})});
    }

    ret->m_info = spec;

    return ret;
}

Variant DynamicBoardDevice::_get(String property) {
    if (auto prop = properties.find(property); prop != properties.end()) {
        return std::visit(Visitor{[](Ref<BoardDeviceMutex> mtx) { return Variant{mtx}; },
                                  [](auto& u) { return Variant{static_cast<int>(u.load())}; }},
                          prop->second);
    }
    return Variant{};
}

bool DynamicBoardDevice::_set(String property, Variant value) {
    Godot::print(property, value);
    if (auto prop = properties.find(property); prop != properties.end()) {
        return std::visit(Visitor{[](Ref<BoardDeviceMutex> mtx) { return false; },
                                  [&](auto& u) {
                                      u.store(value);
                                      return true;
                                  }},
                          prop->second);
    }
    return false;
}

Ref<BoardDeviceSpec> DynamicBoardDevice::info() { return m_info; }

void BoardDeviceMutex::_register_methods() {
    register_method("lock", &BoardDeviceMutex::lock);
    register_method("try_lock", &BoardDeviceMutex::try_lock);
    register_method("unlock", &BoardDeviceMutex::unlock);
}

void BoardDeviceMutex::lock() { mtx.lock(); }

bool BoardDeviceMutex::try_lock() { return mtx.try_lock(); }

void BoardDeviceMutex::unlock() { mtx.unlock(); }
