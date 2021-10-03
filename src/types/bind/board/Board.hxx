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

#include <filesystem>
#include <functional>
#include <memory>
#include <optional>
#include <type_traits>
#include <SMCE/Board.hpp>
#include <SMCE/BoardConf.hpp>
#include <SMCE/SketchConf.hpp>
#include <core/Godot.hpp>
#include <gen/Reference.hpp>
#include "types/Result.hxx"
#include "types/bind/board_view/BoardView.hxx"
#include "types/bind/sketch/Sketch.hxx"
#include "util/Extensions.hxx"
#include "BoardConfig.hxx"

namespace godot {

namespace stdfs = std::filesystem;

class BoardLogReader : public Reference {
    GODOT_CLASS(BoardLogReader, Reference);

  public:
    std::shared_ptr<smce::Board> board;

    static void _register_methods();
    void _init() {}

    Variant read();
};

class Board : public Reference {
    GODOT_CLASS(Board, Reference)

    std::shared_ptr<smce::Board> board;

    Ref<Sketch> m_sketch;

    template <class... Status> bool is_status(Status... x) { return ((board->status() == x) || ...); }

    Ref<BoardView> m_view;

    Ref<BoardLogReader> m_log_reader;

    bool stopped = false;
    int exit_code = 0;
    Ref<Result> exit_code_res = Result::ok();

  public:
    Board();

    Ref<BoardView> get_view();

    void _init();

    static void _register_methods();

    Ref<Result> start(Ref<BoardConfig> board_config, Ref<Sketch> sketch);
    Ref<Result> suspend();
    Ref<Result> resume();
    Ref<Result> stop();

    bool is_active() { return is_status(smce::Board::Status::running, smce::Board::Status::suspended); }

    Ref<BoardLogReader> log_reader() { return m_log_reader; }

    Ref<Result> poll();

    int get_status();

    smce::Board& native();
};
} // namespace godot

#endif // GODOT_SMCE_BOARD_HXX
