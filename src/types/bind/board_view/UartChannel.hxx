/*
 *  UartChannel.hxx
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

#ifndef GODOT_SMCE_UARTSLURPER_HXX
#define GODOT_SMCE_UARTSLURPER_HXX

#include <vector>
#include <core/Godot.hpp>
#include "types/bind/board/BoardConfig.hxx"
#include "BoardView.hxx"

namespace godot {

class UartChannel : public Reference {
    GODOT_CLASS(UartChannel, Reference)

    smce::VirtualUart m_uart = smce::BoardView{}.uart_channels[0];

    String gread_buf;
    std::vector<char> read_buf{};
    std::vector<char> write_buf{};

    Ref<BoardConfig::UartChannelConfig> m_info;

  public:
    static void _register_methods();

    void _init() {}

    static Ref<UartChannel> from_native(Ref<BoardConfig::UartChannelConfig> info, smce::VirtualUart vu);

    void poll();

    void write(String buf);

    String read();

    Ref<BoardConfig::UartChannelConfig> info();
};

} // namespace godot

#endif // GODOT_SMCE_UARTSLURPER_HXX
