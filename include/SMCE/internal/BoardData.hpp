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
#include <cstdint>
#include <deque>
#include <memory>
#include <optional>
#include <vector>
#include <boost/atomic/ipc_atomic.hpp>
#include <boost/atomic/ipc_atomic_flag.hpp>
#include <boost/interprocess/allocators/allocator.hpp>
#include <boost/interprocess/containers/string.hpp>
#include <boost/interprocess/containers/vector.hpp>
#include <boost/interprocess/managed_shared_memory.hpp>
#include <boost/interprocess/sync/interprocess_recursive_mutex.hpp>
#include <SMCE/fwd.hpp>

namespace smce {

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

struct IpcMovableRecursiveMutex : boost::interprocess::interprocess_recursive_mutex {
    IpcMovableRecursiveMutex() noexcept = default;
    IpcMovableRecursiveMutex(IpcMovableRecursiveMutex&&) noexcept {} //HSD never
    IpcMovableRecursiveMutex& operator=(IpcMovableRecursiveMutex&&) noexcept { return *this; } //HSD never
};

template <class T>
using ShmAllocator = boost::interprocess::allocator<T, boost::interprocess::managed_shared_memory::segment_manager>;
template <class T>
using ShmBasicString = boost::interprocess::basic_string<T, std::char_traits<T>, ShmAllocator<T>>;
using ShmString = ShmBasicString<char>;

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
        IpcMovableRecursiveMutex rx_mut;
        IpcMovableRecursiveMutex tx_mut;
        std::deque<char, ShmAllocator<char>> rx; //rw
        std::deque<char, ShmAllocator<char>> tx; //rw
        std::uint16_t max_buffered_rx; //ro
        std::uint16_t max_buffered_tx; //ro
        std::uint16_t baud_rate; //ro
        std::optional<std::uint16_t> rx_pin_override; //ro
        std::optional<std::uint16_t> tx_pin_override; //ro
        explicit UartChannel(const ShmAllocator<void>&);
    };

    boost::interprocess::vector<Pin, ShmAllocator<Pin>> pins; // sorted by id
    boost::interprocess::vector<UartChannel, ShmAllocator<UartChannel>> uart_channels;
    ShmString fqbn;

    BoardData(const ShmAllocator<void>&,
              std::string_view fqbn, const BoardConfig&) noexcept;
};

}

#endif // SMCE_BOARDDATA_HPP
