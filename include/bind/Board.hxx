/*
 *  Board.hxx
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

#ifndef GODOT_SMCE_BOARD_HXX
#define GODOT_SMCE_BOARD_HXX

#include <functional>
#include <optional>
#include <type_traits>
#include <SMCE/BoardConf.hpp>
#include <SMCE/Board.hpp>
#include <SMCE/SketchConf.hpp>
#include <core/Godot.hpp>
#include <gen/Node.hpp>
#include <gen/Reference.hpp>
#include "bind/BoardConfig.hxx"
#include "bind/BoardView.hxx"
#include "bind/UartSlurper.hxx"
#include "bind/Sketch.hxx"
#include "gd/AnyTask.hxx"
#include "gd/GDResult.hxx"
#include "gd/util.hxx"

namespace godot {

namespace stdfs = std::filesystem;

class Board : public Node {
    GODOT_CLASS(Board, Node)

    smce::BoardConfig bconfig;
    smce::Board board;

    Ref<Sketch> sketch;

    template<class ...Status>
    bool is_status(Status ...x) {
        return ((board.status() == x) ||  ...);
    }

    void set_view();

  public:
    Board();

    BoardView* view_node;
    UartSlurper* uart_node;

    BoardView* view();
    UartSlurper* uart();

    void _init();

    static void _register_methods();

    Ref<GDResult> configure(Ref<BoardConfig> board_config);
    Ref<GDResult> reconfigure();

    Ref<GDResult> attach_sketch(Ref<Sketch> sketch);
    Ref<Sketch> get_sketch();
    Ref<GDResult> start();
    Ref<GDResult> suspend();
    Ref<GDResult> resume();
    Ref<GDResult> terminate();
    Ref<GDResult> reset();

    void _physics_process();

    String context();

    int status();

    smce::Board& native();
};
} // namespace godot

#endif // GODOT_SMCE_BOARD_HXX
