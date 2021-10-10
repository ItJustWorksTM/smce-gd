/*
 *  BoardView.cxx
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

#include "BoardView.hxx"
#include "UartChannel.hxx"

using namespace godot;

void BoardView::_init() {}

void BoardView::_register_methods() {
    register_signals<BoardView>("invalidated");
    register_property<BoardView>("pins", &BoardView::set_noop, &BoardView::get_valid<&BoardView::pins>,
                                 Dictionary{});
    register_property<BoardView>("uart_channels", &BoardView::set_noop,
                                 &BoardView::get_valid<&BoardView::uart_channels>, Dictionary{});
    register_property<BoardView>("frame_buffers", &BoardView::set_noop,
                                 &BoardView::get_valid<&BoardView::frame_buffers>, Dictionary{});
    register_property<BoardView>("board_devices", &BoardView::set_noop,
                                 &BoardView::get_valid<&BoardView::board_devices>, Dictionary{});
    register_method("is_valid", &BoardView::is_valid);
}

smce::BoardView BoardView::native() { return view; }

void BoardView::poll() {
    for (int i = 0; i < uart_channels.size(); ++i) {
        static_cast<Ref<UartChannel>>(uart_channels[i])->poll();
    }
}
