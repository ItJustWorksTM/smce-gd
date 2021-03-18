/*
 *  SMCE_numeric.hpp
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

#ifndef SMCE_ARDRIVO_SMCE_NUMERIC_HPP
#define SMCE_ARDRIVO_SMCE_NUMERIC_HPP

#include <cstring>
#include <type_traits>

template <class To, class From>
To SMCE__bit_cast(const From& value) noexcept {
    static_assert(sizeof(To) == sizeof(From), "From and To must be of same size");
    static_assert(std::is_trivially_copyable<From>::value, "From must be trivially copyable");
    static_assert(std::is_trivially_copyable<To>::value, "To must be trivially copyable");
    To ret;
    std::memcpy(&ret, &value, sizeof(To));
    return ret;
}

#endif // SMCE_ARDRIVO_SMCE_NUMERIC_HPP
