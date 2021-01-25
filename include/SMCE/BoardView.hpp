/*
 *  BoardView.hpp
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

#ifndef SMCE_BOARDVIEW_HPP
#define SMCE_BOARDVIEW_HPP

#include <cstdint>
#include <memory_resource>
#include <span>
#include <vector>
#include <SMCE/fwd.hpp>

namespace smce {

class VirtualAnalogDriver {
    friend class VirtualPin;
    BoardData* m_bdat;
    std::size_t m_idx;
    constexpr VirtualAnalogDriver(BoardData* bdat, std::size_t idx) : m_bdat{bdat}, m_idx{idx} {}
  public:
    [[nodiscard]] bool exists() noexcept;
    [[nodiscard]] bool can_read() noexcept;
    [[nodiscard]] bool can_write() noexcept;
    [[nodiscard]] std::uint16_t read() noexcept;
    void write(std::uint16_t) noexcept;
};

class VirtualDigitalDriver {
    friend class VirtualPin;
    BoardData* m_bdat;
    std::size_t m_idx;
    constexpr VirtualDigitalDriver(BoardData* bdat, std::size_t idx) : m_bdat{bdat}, m_idx{idx} {}
  public:
    [[nodiscard]] bool exists() noexcept;
    [[nodiscard]] bool can_read() noexcept;
    [[nodiscard]] bool can_write() noexcept;
    [[nodiscard]] bool read() noexcept;
    void write(bool) noexcept;
};

class VirtualPin {
    friend class VirtualPins;
    BoardData* m_bdat;
    std::size_t m_idx;
    constexpr VirtualPin(BoardData* bdat, std::size_t idx) : m_bdat{bdat}, m_idx{idx} {}
  public:
    enum class DataDirection { in, out };
    [[nodiscard]] bool exists() noexcept;
    [[nodiscard]] bool locked() noexcept;
    void set_direction(DataDirection) noexcept;
    [[nodiscard]] DataDirection get_direction() noexcept;

    [[nodiscard]] VirtualDigitalDriver digital() noexcept { return {m_bdat, m_idx}; }
    [[nodiscard]] VirtualAnalogDriver analog() noexcept { return {m_bdat, m_idx}; }
};

class VirtualPins {
    friend BoardView;
    BoardData* m_bdat;
    explicit VirtualPins(BoardData* bdat) : m_bdat{bdat} {}
  public:
//  struct Iterator;

    [[nodiscard]] VirtualPin operator[](std::size_t idx) noexcept;
//  [[nodiscard]] Iterator begin() noexcept;
//  [[nodiscard]] Iterator end() noexcept;
//  [[nodiscard]] std::size_t size() noexcept;
};

class VirtualUartBuffer {
    friend class VirtualUart;
    enum class Direction { rx, tx };
    BoardData* m_bdat;
    std::size_t m_index;
    Direction m_dir;
    constexpr VirtualUartBuffer(BoardData* bdat, std::size_t idx, Direction dir) : m_bdat{bdat}, m_index{idx}, m_dir{dir} {}
  public:
    [[nodiscard]] bool exists() noexcept;
    [[nodiscard]] std::size_t max_size() noexcept;
    [[nodiscard]] std::size_t size() noexcept;
    std::size_t read(std::span<char>) noexcept;
    std::size_t write(std::span<const char>) noexcept;
    [[nodiscard]] char front() noexcept;
};

class VirtualUart {
    friend class VirtualUarts;
    BoardData* m_bdat;
    std::size_t m_index;
    constexpr VirtualUart(BoardData* bdat, std::size_t idx) : m_bdat{bdat}, m_index{idx} {}
  public:
    [[nodiscard]] bool exists() noexcept;
    [[nodiscard]] bool is_active() noexcept;
    void set_active(bool) noexcept; // Board-only
    VirtualUartBuffer rx() noexcept { return {m_bdat, m_index, VirtualUartBuffer::Direction::rx}; }
    VirtualUartBuffer tx() noexcept { return {m_bdat, m_index, VirtualUartBuffer::Direction::tx}; }
};

class VirtualUarts {
    friend BoardView;
    BoardData* m_bdat;
    constexpr VirtualUarts() noexcept = default;
    constexpr explicit VirtualUarts(BoardData* bdat)
        : m_bdat{bdat}
    {}
    constexpr VirtualUarts(const VirtualUarts&) noexcept = default;
  public:
    class Iterator;
    friend Iterator;

    [[nodiscard]] VirtualUart operator[](std::size_t) noexcept;
    [[nodiscard]] Iterator begin() noexcept;
    [[nodiscard]] Iterator end() noexcept;
    [[nodiscard]] std::size_t size() noexcept;
};

class BoardView {
    BoardData* m_bdat{};
  public:
    VirtualPins pins{m_bdat};
    VirtualUarts uart_channels{m_bdat};
//  VirtualI2cs i2c_buses;
//  VirtualOpaqueDevices opaque_devices;

    constexpr BoardView() noexcept = default;
    explicit BoardView(BoardData& bdat)
        : m_bdat{&bdat}
    {}

    [[nodiscard]] bool valid() noexcept { return m_bdat; }
};

class VirtualUarts::Iterator {
    friend VirtualUarts;
    VirtualUarts m_vu{};
    std::size_t m_index = 0;
    constexpr Iterator() noexcept = default;
    constexpr explicit Iterator(const VirtualUarts& vu, std::size_t idx = 0) noexcept : m_vu{vu}, m_index{idx} {}
  public:
    [[nodiscard]] VirtualUart operator*() noexcept;
    constexpr Iterator& operator++() noexcept { ++m_index; return *this; }
    inline Iterator operator++(int) noexcept { const auto ret = *this; ++m_index; return ret; }
};

}

#endif // SMCE_BOARDVIEW_HPP
