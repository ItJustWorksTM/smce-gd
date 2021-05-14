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
#include <mutex>
#include <boost/date_time/microsec_time_clock.hpp>
#include <boost/date_time/posix_time/ptime.hpp>
#include <boost/date_time/posix_time/posix_time_duration.hpp>
#include "SMCE/internal/BoardData.hpp"
#include "SMCE/internal/utils.hpp"

using microsec_clock = boost::date_time::microsec_clock<boost::posix_time::ptime>;

namespace smce {

[[nodiscard]] std::string_view BoardView::storage_get_root(Link link, std::uint16_t accessor) noexcept {
    if(!m_bdat)
        return {};
    using Bus = BoardData::DirectStorage::Bus;
    constexpr std::array<Bus, 3> link2bus{
        Bus{-1}, // UART
        Bus::SPI, // SPI
        Bus{-1}, // I2C
    };
    const auto bus = link2bus[static_cast<std::size_t>(link)];
    if(bus == Bus{-1})
        return {};

    const auto it =
        std::find_if(
            m_bdat->direct_storages.begin(),
            m_bdat->direct_storages.end(),
            [=](const BoardData::DirectStorage& ds) -> bool {
                return ds.bus == bus && ds.accessor == accessor;
    });
    if(it == m_bdat->direct_storages.end())
        return {};
    return it->root_dir;
}

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
    return exists() ? m_bdat->pins[m_idx].value.load() : 0;
}

void VirtualAnalogDriver::write(std::uint16_t value) noexcept {
    if(exists())
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
    return exists() && m_bdat->pins[m_idx].value.load();
}

void VirtualDigitalDriver::write(bool value) noexcept {
    if(exists())
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
    if (it != m_bdat->pins.end()) {
        if (const auto delta = std::distance(m_bdat->pins.begin(), it); delta >= 0 && m_bdat->pins[delta].id == pin_id)
            return {m_bdat, static_cast<std::size_t>(delta)};
    }
    return {nullptr, std::size_t(-1)};
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
      unreachable();
    }();
    if (!mut.timed_lock(microsec_clock::universal_time() + boost::posix_time::seconds{1}))
        return 0;
    const auto ret = d.size();
    mut.unlock();
    return ret;
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
      unreachable();
    }();
    if (!mut.timed_lock(microsec_clock::universal_time() + boost::posix_time::seconds{1}))
        return 0;
    const std::size_t count = std::min(d.size(), buf.size());
    std::copy_n(d.begin(), count, buf.begin());
    d.erase(d.begin(), d.begin() + count);
    mut.unlock();
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
        unreachable();
    }();
    if (!mut.timed_lock(microsec_clock::universal_time() + boost::posix_time::seconds{1}))
        return 0;
    const std::size_t count = std::min(std::clamp(max_buffered - d.size(), std::size_t{0}, static_cast<std::size_t>(max_buffered)), buf.size());
    std::copy_n(buf.begin(), count, std::back_inserter(d));
    mut.unlock();
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
      unreachable();
    }();
    if (!mut.timed_lock(microsec_clock::universal_time() + boost::posix_time::seconds{1}))
        return 0;
    if(d.empty())
        return '\0';
    const char ret = d.front();
    mut.unlock();
    return ret;
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

[[nodiscard]] bool FrameBuffer::exists() noexcept {
    return m_bdat && m_idx < m_bdat->frame_buffers.size();
}

[[nodiscard]] auto FrameBuffer::direction() noexcept -> Direction {
    return exists() ? Direction{static_cast<uint8_t>(m_bdat->frame_buffers[m_idx].direction)} : Direction::in;
}

[[nodiscard]] bool FrameBuffer::needs_horizontal_flip() noexcept {
    return exists() && m_bdat->frame_buffers[m_idx].transform.load().horiz_flip;
}

void FrameBuffer::needs_horizontal_flip(bool val) noexcept {
    if(!exists())
        return;

    auto trans = m_bdat->frame_buffers[m_idx].transform.load();
    trans.horiz_flip = val;
    m_bdat->frame_buffers[m_idx].transform.store(trans);
}

[[nodiscard]] bool FrameBuffer::needs_vertical_flip() noexcept {
    return exists() && m_bdat->frame_buffers[m_idx].transform.load().vert_flip;
}

void FrameBuffer::needs_vertical_flip(bool val) noexcept {
    if(!exists())
        return;

    auto trans = m_bdat->frame_buffers[m_idx].transform.load();
    trans.vert_flip = val;
    m_bdat->frame_buffers[m_idx].transform.store(trans);
}

[[nodiscard]] std::uint16_t FrameBuffer::get_width() noexcept {
    return exists() ? m_bdat->frame_buffers[m_idx].width.load() : 0;
}

void FrameBuffer::set_width(std::uint16_t width) noexcept {
    if(!exists())
        return;
    auto& fb = m_bdat->frame_buffers[m_idx];
    fb.width = width;
    fb.data.resize(width * fb.height * 3);
}

[[nodiscard]] std::uint16_t FrameBuffer::get_height() noexcept {
    return exists() ? m_bdat->frame_buffers[m_idx].height.load() : 0;
}

void FrameBuffer::set_height(std::uint16_t height) noexcept {
    if(!exists())
        return;
    auto& fb = m_bdat->frame_buffers[m_idx];
    fb.height = height;
    fb.data.resize(height * fb.width * 3);
}

[[nodiscard]] std::uint8_t FrameBuffer::get_freq() noexcept {
    return exists() ? m_bdat->frame_buffers[m_idx].freq.load() : 0;
}

void FrameBuffer::set_freq(std::uint8_t freq) noexcept {
    if(!exists())
        return;
    m_bdat->frame_buffers[m_idx].freq = freq;
}

bool FrameBuffer::write_rgb888(std::span<const std::byte> buf) {
    if(!exists())
        return false;

    auto& frame_buf = m_bdat->frame_buffers[m_idx];
    if(buf.size() != frame_buf.data.size())
        return false;

    [[maybe_unused]] std::lock_guard lk{frame_buf.data_mut};
    std::memcpy(frame_buf.data.data(), buf.data(), buf.size());
    return true;
}

bool FrameBuffer::read_rgb888(std::span<std::byte> buf) {
    if(!exists())
        return false;

    auto& frame_buf = m_bdat->frame_buffers[m_idx];
    if(buf.size() != frame_buf.data.size())
        return false;
    [[maybe_unused]] std::lock_guard lk{frame_buf.data_mut};
    std::memcpy(buf.data(), frame_buf.data.data(), buf.size());
    return true;
}

bool FrameBuffer::write_rgb444(std::span<const std::byte> buf) {
    if(!exists())
        return false;

    auto& frame_buf = m_bdat->frame_buffers[m_idx];
    if(buf.size() != frame_buf.data.size() / 2)
        return false;

    [[maybe_unused]] std::lock_guard lk{frame_buf.data_mut};

    auto* to = frame_buf.data.data();
    for(std::byte from : buf) {
        *to++ = from & std::byte{0xF};
        *to++ = from << 4; // Might be a bug there in the case where we have an odd number of pixels in the frame
    }

    return true;
}

bool FrameBuffer::read_rgb444(std::span<std::byte> buf) {
    if(!exists())
        return false;

    auto& frame_buf = m_bdat->frame_buffers[m_idx];
    if(buf.size() != frame_buf.data.size())
        return false;
    [[maybe_unused]] std::lock_guard lk{frame_buf.data_mut};

    const auto* from = frame_buf.data.data();
    for(std::byte& to : buf) {
        to = (from[0] & std::byte{0xF}) | (from[1] >> 4);
        from += 2;
    }

    return true;
}

FrameBuffer FrameBuffers::operator[](std::size_t key) noexcept {
    if(!m_bdat)
        return {m_bdat, 0};
    const auto it = std::lower_bound(
        m_bdat->frame_buffers.begin(),
        m_bdat->frame_buffers.end(), key,
        [](const auto& pin, std::size_t key){
          return pin.key < key;
        });
    if (it != m_bdat->frame_buffers.end()) {
        if (const auto delta = std::distance(m_bdat->frame_buffers.begin(), it); delta >= 0 && m_bdat->frame_buffers[delta].key == key)
            return {m_bdat, static_cast<std::size_t>(delta)};
    }
    return {nullptr, std::size_t(-1)};
}

}
