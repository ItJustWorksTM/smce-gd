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
#include <span>
#include <SMCE/fwd.hpp>

namespace smce {

/**
 * Analog driver for a GPIO pin
 **/
class VirtualAnalogDriver {
    friend class VirtualPin;
    BoardData* m_bdat;
    std::size_t m_idx;
    constexpr VirtualAnalogDriver(BoardData* bdat, std::size_t idx) : m_bdat{bdat}, m_idx{idx} {}
  public:
    /// Object validity check
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
    /// Object validity check
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
    /// Object validity check
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
    /// Object validity check
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
    /// Object validity check
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
  public:
    class Iterator;
    friend Iterator;

    constexpr VirtualUarts(const VirtualUarts&) noexcept = default;

    [[nodiscard]] VirtualUart operator[](std::size_t) noexcept;
    [[nodiscard]] Iterator begin() noexcept;
    [[nodiscard]] Iterator end() noexcept;
    [[nodiscard]] std::size_t size() noexcept;
};

/**
 * An RGB888 framebuffer, holding a single frame.
 * Intended to be used to implement cameras and screen library shims.
 **/
class FrameBuffer {
    friend class FrameBuffers;
    BoardData* m_bdat;
    std::size_t m_idx;

    constexpr FrameBuffer(BoardData* bdat, std::size_t idx) noexcept : m_bdat{bdat}, m_idx{idx} {}
  public:
    /// Data direction
    enum struct Direction {
        in, /// host-to-board (camera)
        out, /// board-to-host (screen)
    };

    /// Object validity check
    [[nodiscard]] bool exists() noexcept;
    /// Data direction getter
    [[nodiscard]] Direction direction() noexcept;

    /// Flag getter for hflip
    [[nodiscard]] bool needs_horizontal_flip() noexcept;
    /// Flag setter for hflip
    void needs_horizontal_flip(bool) noexcept;
    /// Flag getter for vflip
    [[nodiscard]] bool needs_vertical_flip() noexcept;
    /// Flag setter for vflip
    void needs_vertical_flip(bool) noexcept;

    /// \note Size in px
    [[nodiscard]] std::uint16_t get_width() noexcept;
    /// \note Size in px
    void set_width(std::uint16_t) noexcept;
    /// \note Size in px
    [[nodiscard]] std::uint16_t get_height() noexcept;
    /// \note Size in px
    void set_height(std::uint16_t) noexcept;

    /// \note Frequency is in Hz
    [[nodiscard]] std::uint8_t get_freq() noexcept;
    /// \note Frequency is in Hz
    void set_freq(std::uint8_t) noexcept;

    /// Copies a frame from an RGB888 buffer
    bool write_rgb888(std::span<const std::byte>);
    /// Copies a frame into an RGB888 buffer
    bool read_rgb888(std::span<std::byte>);
};

class FrameBuffers {
    friend BoardView;
    BoardData* m_bdat;
    constexpr FrameBuffers() noexcept = default;
    constexpr explicit FrameBuffers(BoardData* bdat) noexcept : m_bdat{bdat} {}
  public:
    constexpr FrameBuffers(const FrameBuffers&) noexcept = default;

    [[nodiscard]] FrameBuffer operator[](std::size_t) noexcept;
};

/**
 * Mutable view of the virtual board.
 * \note Must stay a no-fail interface (operations all silently fail on error and never cause UB)
 **/
class BoardView {
    BoardData* m_bdat{};
  public:
    VirtualPins pins{m_bdat}; /// GPIO pins
    VirtualUarts uart_channels{m_bdat}; /// UART channels
//  VirtualI2cs i2c_buses;
//  VirtualOpaqueDevices opaque_devices;
    FrameBuffers frame_buffers{m_bdat}; /// Camera/Screen frame-buffers

    constexpr BoardView() noexcept = default;
    explicit BoardView(BoardData& bdat)
        : m_bdat{&bdat}
    {}

    /// Object validity check
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
