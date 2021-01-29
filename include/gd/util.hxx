/*
 *  EmulGlue.hxx
 *  Copyright 2020 ItJustWorksTM
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

#ifndef GODOT_SMCE_UTIL_HXX
#define GODOT_SMCE_UTIL_HXX

#include <concepts>
#include "core/Godot.hpp"

template <std::derived_from<godot::Reference> T> auto make_ref() -> godot::Ref<T> { return T::_new(); }

constexpr auto register_fns = []<class... T>(std::pair<const char*, T>... func) {
    (register_method(func.first, func.second), ...);
};

#define MEMBER_LAMBDA()                                                                                      \
    template <auto func, class Ret = void, class... Args> constexpr auto lambda(Args... args)->Ret {         \
        return std::invoke(func, *this, args...);                                                            \
    }

#endif // GODOT_SMCE_UTIL_HXX
