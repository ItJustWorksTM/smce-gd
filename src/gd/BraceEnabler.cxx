/*
 *  BraceEnabler.cxx
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

#include <cstddef>
#include <core/Godot.hpp>
#include <gen/Node.hpp>
#include <gen/__icalls.hpp>

#include "gd/BraceEnabler.hxx"

namespace godot {

void BraceEnabler::_register_methods() { register_method("_notification", &BraceEnabler::_notification); }

void BraceEnabler::_init() {}

void BraceEnabler::_notification(int what) {
    if (what != Node::NOTIFICATION_PARENTED)
        return;

    auto* parent = get_parent();
    if (!parent || !parent->is_class("TextEdit"))
        return;

    static std::ptrdiff_t offset = [=] {
        const auto getter =
            godot::api->godot_method_bind_get_method("TextEdit", "is_highlight_current_line_enabled");
        const auto setter =
            godot::api->godot_method_bind_get_method("TextEdit", "set_highlight_current_line");
        const auto get = [=]() { return ___godot_icall_bool(getter, parent); };
        const auto set = [=](bool enabled) { ___godot_icall_void_bool(setter, parent, enabled); };

        const auto prev = get();

        auto* const base = reinterpret_cast<unsigned char*>(parent->_owner);
        auto* ptr = base;
        for (;; ++ptr) {
            set(false);
            while (*ptr)
                ++ptr;
            set(true);
            if (*ptr == static_cast<unsigned char>(true)) {
                set(prev);
                return ptr - base - 1;
            }
        }
    }();

    *(reinterpret_cast<volatile unsigned char*>(parent->_owner) + offset) = true;
}

} // namespace godot
