/*
 *  BoardView.cpp
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

#include "SMCE/BoardView.hpp"

#include <iterator>
#include "SMCE/internal/BoardData.hpp"

namespace smce {

[[nodiscard]] bool VirtualAnalogDriver::exists() noexcept {
    return m_bdat && m_idx < m_bdat->pins.size();
}

[[nodiscard]] bool VirtualAnalogDriver::can_read() noexcept {
    return exists() && m_bdat->pins[m_idx].can_analog_read;
}

[[nodiscard]] bool VirtualAnalogDriver::can_write() noexcept {
    return exists() && m_bdat->pins[m_idx].can_analog_write;
}

[[nodiscard]] std::uint16_t VirtualAnalogDriver::read() noexcept {
    return exists() && can_read() ? m_bdat->pins[m_idx].value.load() : 0;
}

void VirtualAnalogDriver::write(std::uint16_t value) noexcept {
    if(exists() && can_write())
        m_bdat->pins[m_idx].value.store(value);
}

[[nodiscard]] bool VirtualDigitalDriver::exists() noexcept {
    return m_bdat && m_idx < m_bdat->pins.size();
}

[[nodiscard]] bool VirtualDigitalDriver::can_read() noexcept {
    return exists() && m_bdat->pins[m_idx].can_digital_read;
}

[[nodiscard]] bool VirtualDigitalDriver::can_write() noexcept {
    return exists() && m_bdat->pins[m_idx].can_digital_write;
}

[[nodiscard]] bool VirtualDigitalDriver::read() noexcept {
    return exists() && can_read() && m_bdat->pins[m_idx].value.load();
}

void VirtualDigitalDriver::write(bool value) noexcept {
    if(exists() && can_write())
        m_bdat->pins[m_idx].value.store(value ? 255 : 0);
}

[[nodiscard]] bool VirtualPin::exists() noexcept {
    return m_bdat && m_idx < m_bdat->pins.size();
}

[[nodiscard]] bool VirtualPin::locked() noexcept {
    return !exists() || m_bdat->pins[m_idx].active_driver != BoardData::Pin::ActiveDriver::gpio;
}

void VirtualPin::set_direction(DataDirection dir) noexcept {
    if(exists() && !locked())
        m_bdat->pins[m_idx].data_direction = static_cast<BoardData::Pin::DataDirection>(dir);
}

[[nodiscard]] auto VirtualPin::get_direction() noexcept -> DataDirection {
    return exists() && !locked()
               ? static_cast<DataDirection>(m_bdat->pins[m_idx].data_direction.load())
               : DataDirection::in;
}

VirtualPin VirtualPins::operator[](std::size_t pin_id) noexcept {
    if(!m_bdat)
        return {m_bdat, 0};
    const auto it = std::lower_bound(
        m_bdat->pins.begin(),
        m_bdat->pins.end(), pin_id,
        [](const auto& pin, std::size_t pin_id){
        return pin.id < pin_id;
    });
    return {m_bdat, static_cast<std::size_t>(std::distance(it, m_bdat->pins.begin()))};
}

[[nodiscard]] bool VirtualUartBuffer::exists() noexcept {
    return m_bdat && m_index < m_bdat->uart_channels.size();
}

[[nodiscard]] std::size_t VirtualUartBuffer::max_size() noexcept {
    return exists() ? (m_dir == Direction::rx
                           ? m_bdat->uart_channels[m_index].max_buffered_rx
                           : m_bdat->uart_channels[m_index].max_buffered_tx) : 0;
}

[[nodiscard]] std::size_t VirtualUartBuffer::size() noexcept {
    if(!exists())
        return 0;
    auto& chan = m_bdat->uart_channels[m_index];
    auto [d, mut] = [&]{
      switch(m_dir) {
      case Direction::rx: return std::tie(chan.rx, chan.rx_mut);
      case Direction::tx: return std::tie(chan.tx, chan.tx_mut);
      }
    }();
    std::lock_guard g{mut};
    return d.size();
}

std::size_t VirtualUartBuffer::read(std::span<char> buf) noexcept {
    if(!exists())
        return 0;
    auto& chan = m_bdat->uart_channels[m_index];
    auto [d, mut, max_buffered] = [&]{
      switch(m_dir) {
      case Direction::rx:
          return std::tie(chan.rx, chan.rx_mut, chan.max_buffered_rx);
      case Direction::tx:
          return std::tie(chan.tx, chan.tx_mut, chan.max_buffered_tx);
      }
    }();
    std::lock_guard g{mut};
    const std::size_t count = std::min(d.size(), buf.size());
    std::copy_n(d.begin(), count, buf.begin());
    d.erase(d.begin(), d.begin() + count);
    return count;
}

std::size_t VirtualUartBuffer::write(std::span<const char> buf) noexcept {
    if(!exists())
        return 0;
    auto& chan = m_bdat->uart_channels[m_index];
    auto [d, mut, max_buffered] = [&]{
        switch(m_dir) {
        case Direction::rx:
            return std::tie(chan.rx, chan.rx_mut, chan.max_buffered_rx);
        case Direction::tx:
            return std::tie(chan.tx, chan.tx_mut, chan.max_buffered_tx);
        }
    }();
    std::lock_guard g{mut};
    const std::size_t count = std::min(std::clamp(max_buffered - d.size(), 0ul, static_cast<std::size_t>(max_buffered)), buf.size());
    std::copy_n(buf.begin(), count, std::back_inserter(d));
    return count;
}

[[nodiscard]] char VirtualUartBuffer::front() noexcept {
    if(!exists())
        return '\0';
    auto& chan = m_bdat->uart_channels[m_index];
    auto [d, mut] = [&]{
      switch(m_dir) {
      case Direction::rx: return std::tie(chan.rx, chan.rx_mut);
      case Direction::tx: return std::tie(chan.tx, chan.tx_mut);
      }
    }();
    std::lock_guard g{mut};
    if(d.empty())
        return '\0';
    return d.front();
}

[[nodiscard]] bool VirtualUart::exists() noexcept {
    return m_bdat && m_index < m_bdat->uart_channels.size();
}

[[nodiscard]] bool VirtualUart::is_active() noexcept {
    return exists() && m_bdat->uart_channels[m_index].active.load();
}

void VirtualUart::set_active(bool value) noexcept {
    if(exists())
        m_bdat->uart_channels[m_index].active.store(value);
}

[[nodiscard]] VirtualUart VirtualUarts::operator[](std::size_t idx) noexcept {
    if(!m_bdat || m_bdat->uart_channels.size() <= idx)
        return VirtualUart{m_bdat, idx};
    return VirtualUart{m_bdat, idx};
}

[[nodiscard]] auto VirtualUarts::begin() noexcept -> Iterator {
    return Iterator{*this};
}

[[nodiscard]] auto VirtualUarts::end() noexcept -> Iterator {
    return Iterator{*this, size()};
}

[[nodiscard]] std::size_t VirtualUarts::size() noexcept {
    return m_bdat ? m_bdat->uart_channels.size() : 0;
}

[[nodiscard]] VirtualUart VirtualUarts::Iterator::operator*() noexcept {
    return m_vu[m_index];
}

}
