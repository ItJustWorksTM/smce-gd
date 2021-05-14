/*
 *  BoardData.hpp
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

#ifndef SMCE_BOARDDATA_HPP
#define SMCE_BOARDDATA_HPP

#include <atomic>
#include <cstddef>
#include <cstdint>
#include <deque>
#include <memory>
#include <optional>
#include <vector>

#include <boost/predef.h>

#include <boost/atomic/ipc_atomic.hpp>
#include <boost/atomic/ipc_atomic_flag.hpp>
#include <boost/interprocess/allocators/allocator.hpp>
#include <boost/interprocess/containers/deque.hpp>
#include <boost/interprocess/containers/string.hpp>
#include <boost/interprocess/containers/vector.hpp>
#if BOOST_OS_WINDOWS
#include <boost/interprocess/managed_windows_shared_memory.hpp>
#else
#include <boost/interprocess/managed_shared_memory.hpp>
#endif
#include <boost/interprocess/sync/spin/mutex.hpp>
#include <SMCE/fwd.hpp>

namespace smce {

/// \internal
template <class T>
struct IpcAtomicValue : boost::ipc_atomic<T> {
    using boost::ipc_atomic<T>::ipc_atomic;
    IpcAtomicValue() noexcept = default;
    constexpr IpcAtomicValue(const IpcAtomicValue& other) noexcept : boost::ipc_atomic<T>{other.load()} {}
    constexpr IpcAtomicValue(IpcAtomicValue&& other) noexcept : boost::ipc_atomic<T>{other.load()} {}
    using boost::ipc_atomic<T>::operator=;
    IpcAtomicValue& operator=(const IpcAtomicValue& other) noexcept { boost::ipc_atomic<T>::store(other.load()); return *this; } // never
    IpcAtomicValue& operator=(IpcAtomicValue&& other) noexcept { boost::ipc_atomic<T>::store(other.load()); return *this; }
};

/// \internal
struct IpcMovableMutex : boost::interprocess::ipcdetail::spin_mutex {
    IpcMovableMutex() noexcept = default;
    IpcMovableMutex(IpcMovableMutex&&) noexcept {} //HSD never
    IpcMovableMutex& operator=(IpcMovableMutex&&) noexcept { return *this; } //HSD never
};

#if BOOST_OS_WINDOWS
using Shm = boost::interprocess::managed_windows_shared_memory;
#else
using Shm = boost::interprocess::managed_shared_memory;
#endif

/// \internal
template <class T>
using ShmAllocator = boost::interprocess::allocator<T, Shm::segment_manager>;
/// \internal
template <class T>
using ShmBasicString = boost::interprocess::basic_string<T, std::char_traits<T>, ShmAllocator<T>>;
/// \internal
using ShmString = ShmBasicString<char>;

/// \internal
struct BoardData {
    struct Pin {
        enum class DataDirection {
            in,
            out,
        };
        enum class ActiveDriver {
            gpio,
            uart,
            i2c,
            spi,
            opaque
        };
        std::uint16_t id; //ro
        bool can_digital_read = false; //ro
        bool can_digital_write = false; //ro
        bool can_analog_read = false; //ro
        bool can_analog_write = false; //ro
        IpcAtomicValue<std::uint16_t> value = 0; //rw
        IpcAtomicValue<DataDirection> data_direction = DataDirection::in; //rw
        IpcAtomicValue<ActiveDriver> active_driver = ActiveDriver::gpio; //rw
    };
    struct UartChannel {
        IpcAtomicValue<bool> active = false; //rw
        IpcMovableMutex rx_mut;
        IpcMovableMutex tx_mut;
        boost::interprocess::deque<char, ShmAllocator<char>> rx; //rw
        boost::interprocess::deque<char, ShmAllocator<char>> tx; //rw
        std::uint16_t max_buffered_rx; //ro
        std::uint16_t max_buffered_tx; //ro
        std::uint16_t baud_rate; //ro
        std::optional<std::uint16_t> rx_pin_override; //ro
        std::optional<std::uint16_t> tx_pin_override; //ro
        explicit UartChannel(const ShmAllocator<void>&);
    };
    struct DirectStorage {
        enum class Bus {
            SPI
        };
        Bus bus;
        std::uint16_t accessor;
        ShmString root_dir;
        explicit DirectStorage(const ShmAllocator<void>&);
    };
    struct FrameBuffer {
        enum struct Direction {
            in,
            out,
        };
        enum PixelFormat : std::uint8_t {
            RGB888,
            RGB444,
            RGB565,
        };
        struct Transform {
            std::uint8_t horiz_flip : 1 = false;
            std::uint8_t vert_flip : 1 = false;
            std::uint8_t pixel_format : 6 = RGB888;
        };
        std::size_t key; //ro
        Direction direction; // ro
        IpcAtomicValue<std::uint16_t> width = 0; //rw
        IpcAtomicValue<std::uint16_t> height = 0; //rw
        IpcAtomicValue<std::uint8_t> freq = 0; //rw
        IpcAtomicValue<Transform> transform{}; //rw
        IpcMovableMutex data_mut;
        boost::interprocess::vector<std::byte, ShmAllocator<std::byte>> data; //rw
        explicit FrameBuffer(const ShmAllocator<void>&);
    };

    boost::interprocess::vector<Pin, ShmAllocator<Pin>> pins; // sorted by id
    boost::interprocess::vector<UartChannel, ShmAllocator<UartChannel>> uart_channels;
    boost::interprocess::vector<DirectStorage, ShmAllocator<DirectStorage>> direct_storages;
    boost::interprocess::vector<FrameBuffer, ShmAllocator<FrameBuffer>> frame_buffers;

    BoardData(const ShmAllocator<void>&, const BoardConfig&) noexcept;
};

}

#endif // SMCE_BOARDDATA_HPP
