/*
 *  utils.hpp
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

#ifndef SMCE_UTILS_HPP
#define SMCE_UTILS_HPP

#include <type_traits>
#include <utility>

namespace smce {

/**
 * UBaaS - UB-as-a-Service
 **/
[[noreturn]] inline void unreachable() noexcept {
#if _MSC_VER
    __assume(false);
#elif __GNUC__
    __builtin_unreachable();
#endif
}

/**
 * Jason Turner's C++ Weekly visitor
 * \tparam Base - Callables to inherit from; intended to be provided via CTAD
 **/
template <class... Base>
struct Visitor : Base... {
    template <class... Ts>
    constexpr Visitor(Ts&&... ts) noexcept((std::is_nothrow_move_constructible_v<Base> && ...))
        : Base{std::forward<Ts>(ts)}... {}
    using Base::operator()...;
};
template <class... Ts>
Visitor(Ts...) -> Visitor<std::remove_cvref_t<Ts>...>;

} // namespace smce

#endif // SMCE_UTILS_HPP
