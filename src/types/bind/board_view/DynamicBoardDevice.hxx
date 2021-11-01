/*
 *  DynamicBoardDevice.hxx
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

#ifndef GODOT_SMCE_DYNAMICBOARDDEVICE_HXX
#define GODOT_SMCE_DYNAMICBOARDDEVICE_HXX

#include <map>
#include <variant>
#include <SMCE/BoardView.hpp>
#include <SMCE/internal/BoardDeviceSpecification.hpp>
#include <SMCE_rt/SMCE_proxies.hpp>
#include <SMCE_rt/internal/host_rt.hpp>
#include "gen/Reference.hpp"
#include "types/bind/board/BoardDeviceSpec.hxx"
#include "util/Extensions.hxx"
#include "Godot.hpp"

#include <type_traits>
#include <utility>

namespace smce_rt {
struct Impl {};
} // namespace smce_rt

namespace godot {

class DynamicBoardDevice;

class BoardDeviceMutex : public GdRef<"BoardDeviceMutex", BoardDeviceMutex> {

    friend DynamicBoardDevice;

    smce_rt::Mutex mtx{};

  public:
    static void _register_methods();

    void lock();

    bool try_lock();

    void unlock();
};

class DynamicBoardDevice : public GdRef<"DynamicBoardDevice", DynamicBoardDevice> {

    using PropType =
        std::variant<smce_rt::AtomicU8, smce_rt::AtomicU16, smce_rt::AtomicU32, Ref<BoardDeviceMutex>>;
    std::map<String, PropType> properties;

    Ref<BoardDeviceSpec> m_info;

  public:
    static void _register_methods();

    static Ref<DynamicBoardDevice> create(Ref<BoardDeviceSpec> spec, smce::BoardView& bv);

    Variant _get(String property);

    bool _set(String property, Variant value);

    Ref<BoardDeviceSpec> info();

    // TODO: implement _get_property_list
};

} // namespace godot

#endif
