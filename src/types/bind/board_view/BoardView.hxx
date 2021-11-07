/*
 *  BoardView.hxx
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

#ifndef GODOT_SMCE_BOARDVIEW_HXX
#define GODOT_SMCE_BOARDVIEW_HXX

#include <functional>
#include <type_traits>
#include <SMCE/BoardConf.hpp>
#include <SMCE/BoardView.hpp>
#include <core/Godot.hpp>
#include "util/Extensions.hxx"
#include "FrameBuffer.hxx"
#include "GpioPin.hxx"

namespace godot {
class Board;

class BoardView : public GdRef<"BoardView", BoardView> {
    friend Board;

    smce::BoardView view;
    bool valid = false;

    Dictionary pins;
    Array uart_channels;
    Dictionary frame_buffers;
    Dictionary /* <String, Array<DynamicBoardDevice>> */ board_devices;

  public:
    static void _register_methods();

    void _init();

    smce::BoardView native();

    void poll();

    bool is_valid() { return valid; }

    template <auto v> auto get_valid() {
        return valid ? this->*v : std::remove_cvref_t<decltype(this->*v)>{};
    }
    void set_noop(auto) {}
};
} // namespace godot

#endif // GODOT_SMCE_BOARDVIEW_HXX
