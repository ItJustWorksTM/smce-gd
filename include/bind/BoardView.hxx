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
#include <SMCE/BoardConf.hpp>
#include <SMCE/BoardView.hpp>
#include <core/Godot.hpp>
#include <gen/Node.hpp>
#include "gd/util.hxx"
#include "FrameBuffer.hxx"

namespace godot {
class BoardRunner;

class BoardView : public Node {
    GODOT_CLASS(BoardView, Node)
    friend BoardRunner;

    smce::BoardView view;

    void set_view(smce::BoardView v);

  public:
    static void _register_methods();

    void _init();

    smce::BoardView native();

    bool is_valid() { return view.valid(); }

    void write_analog_pin(int pin, int value);
    void write_digital_pin(int pin, bool value);

    int read_analog_pin(int pin);
    bool read_digital_pin(int pin);

    Ref<FrameBuffer> framebuffers(int id);
};
} // namespace godot

#endif // GODOT_SMCE_BOARDVIEW_HXX
