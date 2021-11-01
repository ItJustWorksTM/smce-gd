/*
 *  Board.cxx
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

#include <iostream>
#include "bind/Board.hxx"
#include "bind/BoardView.hxx"

using namespace godot;

#define STR(s) #s
#define U(f)                                                                                                 \
    std::pair { STR(f), &Board::f }

void Board::_register_methods() {
    register_signals<Board>("initialized", "configured", "started", "suspended_resumed", "stopped", "cleaned",
                            "log");

    register_fns(U(reset), U(start), U(suspend), U(resume), U(terminate), U(configure), U(status), U(view),
                 U(uart), U(_physics_process), U(attach_sketch), U(get_sketch));
}

#undef STR
#undef U

Board::Board()
    : board{[&](int res) {
          set_view();
          emit_signal("stopped", res);
      }} {}

void Board::_init() {
    view_node = BoardView::_new();
    uart_node = UartSlurper::_new();
    add_child(view_node);
    add_child(uart_node);

    set_physics_process(false);
}

smce::Board& Board::native() { return board; }

void Board::set_view() {
    auto view = board.view();
    view_node->set_view(view);
    uart_node->set_view(view);
}

Ref<GDResult> Board::configure(Ref<BoardConfig> board_config) {
    if (!board_config.is_valid())
        return GDResult::err("Invalid BoardConfig");

    bconfig = board_config->to_native();

    auto res = reconfigure();

    if (res->is_ok())
        emit_signal("configured");

    return res;
}

Ref<GDResult> Board::reconfigure() {
    if (!is_status(smce::Board::Status::clean))
        return GDResult::err("Board not clean");
    if (!board.configure(bconfig))
        return GDResult::err("Failed to configure internal runner");
    if (sketch.is_valid())
        if (auto res = attach_sketch(sketch); !res->is_ok())
            return res;

    set_view();

    return GDResult::ok();
}

Ref<GDResult> Board::attach_sketch(Ref<Sketch> sketch) {
    if (sketch.is_null())
        return GDResult::err("Invalid sketch");

    if (is_status(smce::Board::Status::running, smce::Board::Status::running))
        return GDResult::err("Board still running");

    if (!board.attach_sketch(sketch->native()))
        return GDResult::err("Failed to attach sketch");

    this->sketch = sketch;

    return GDResult::ok();
}

Ref<GDResult> Board::start() {
    if (sketch.is_null())
        return GDResult::err("No sketch attached");
    if (!sketch->is_compiled())
        return GDResult::err("Sketch is not compiled");
    if (is_status(smce::Board::Status::clean))
        return GDResult::err("Board not configured");
    if (is_status(smce::Board::Status::running, smce::Board::Status::suspended))
        return GDResult::err("Board already started");

    // Workaround for libSMCE crash when starting a sketch again
    if (is_status(smce::Board::Status::stopped)) {
        if (!board.reset())
            return GDResult::err("Failed to reset");
        if (auto res = reconfigure(); !res->is_ok())
            return res;
    }

    if (!board.start())
        return GDResult::err("Failed to start internal runner");

    set_view();
    emit_signal("started");
    set_physics_process(true);
    return GDResult::ok();
}

Ref<GDResult> Board::suspend() {
    if (!is_status(smce::Board::Status::running))
        return GDResult::err("Sketch is not running");
    if (!board.suspend())
        return GDResult::err("Failed to suspend internal runner");
    emit_signal("suspended_resumed", true);
    return GDResult::ok();
}

Ref<GDResult> Board::resume() {
    if (!is_status(smce::Board::Status::suspended))
        return GDResult::err("Sketch is not suspended");
    if (!board.resume())
        return GDResult::err("Failed to resume internal runner");
    emit_signal("suspended_resumed", false);
    return GDResult::ok();
}

Ref<GDResult> Board::reset() {
    if (!board.reset())
        return GDResult::err("Failed to reset");

    emit_signal("cleaned");

    return GDResult::ok();
}

void Board::_physics_process() {
    auto [_, str] = board.runtime_log();

    if (!is_status(smce::Board::Status::running, smce::Board::Status::suspended) && str.empty())
        set_physics_process(false);

    if (!str.empty()) {
        std::replace_if(
            str.begin(), str.end(), [](const auto& c) { return c == '\r'; }, '\t');
        emit_signal("log", String{str.data()});
        std::cout << str;
        str.clear();
    }

    board.tick();
}

Ref<GDResult> Board::terminate() {
    if (!board.terminate())
        return GDResult::err("Failed to terminate internal runner");

    set_view();

    emit_signal("stopped", 0);

    return GDResult::ok();
}

int Board::status() { return static_cast<int>(board.status()); }

UartSlurper* Board::uart() { return uart_node; }

BoardView* Board::view() { return view_node; }

Ref<Sketch> Board::get_sketch() { return sketch; }
