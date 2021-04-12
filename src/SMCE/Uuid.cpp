/*
 *  Uuid.cpp
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

#include <SMCE/Uuid.hpp>

#include <array>
#include <cstring>
#include <mutex>
#include <random>
#include <boost/iterator/counting_iterator.hpp>
#include <boost/iterator/transform_iterator.hpp>

namespace {

// Derived from https://codereview.stackexchange.com/a/109266
template <class T = std::mt19937_64, std::size_t N = T::state_size * sizeof(typename T::result_type)>
T ProperlySeededRandomEngine() noexcept {
    std::random_device source;
    auto make_iter = [&](std::size_t n) {
      return boost::make_transform_iterator(
          boost::counting_iterator<std::size_t>(n), [&](std::size_t){ return source(); });
    };
    std::seed_seq seeds(make_iter(0), make_iter((N - 1) / sizeof(source()) + 1));
    return T{seeds};
}

}

namespace smce {

std::string Uuid::to_hex() const noexcept {
    constexpr auto hexstr = "0123456789ABCDEF";
    std::string ret;
    ret.reserve(bytes.size() * 2);
    for (const std::byte v : bytes) {
        ret.push_back(hexstr[std::to_integer<int>(v >> 4)]);
        ret.push_back(hexstr[std::to_integer<int>(v & std::byte{0xF})]);
    }
    return ret;
}

Uuid Uuid::generate() noexcept {
    static std::mt19937_64 gen = ProperlySeededRandomEngine<>();
    static std::mutex gen_mtx;
    [[maybe_unused]] std::lock_guard lk{gen_mtx};
    Uuid ret;
    const uint64_t data[2]{gen(), gen()};
    std::memcpy(ret.bytes.data(), data, ret.bytes.size());
    return ret;
}

}
