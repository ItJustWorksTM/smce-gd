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

#include "types/bind/board_view/BoardView.hxx"
#include "types/bind/board_view/UartChannel.hxx"
#include "Board.hxx"

using namespace godot;

#define STR(s) #s
#define U(f)                                                                                                 \
    std::pair { STR(f), &Board::f }

void Board::_register_methods() {
    register_signals<Board>("status_changed", "log_changed", "crashed");

    register_fns(U(start), U(suspend), U(resume), U(stop), U(get_status), U(get_view), U(poll), U(get_log),
                 U(_on_sketch_locked), U(is_active));
}

#undef STR
#undef U

Board::Board()
    : board{[&](int res) {
          exit_code = res;
          exit_code_res->set_err(exit_code);
          m_view->valid = false;
          m_view->emit_signal("invalidated");
          emit_signal("crashed");
          emit_status_changed();
      }} {}

void Board::_init() { m_view = make_ref<BoardView>(); }

smce::Board& Board::native() { return board; }

Ref<Result> Board::start(Ref<BoardConfig> board_config, Ref<Sketch> sketch) {
    if (!is_status(smce::Board::Status::clean))
        return Result::err("Board already in use");
    if (!sketch->is_compiled())
        return Result::err("Sketch is not compiled");
    if (!board.configure(board_config->to_native()))
        return Result::err("Failed to configure board");
    if (!board.attach_sketch(sketch->native()))
        return Result::err("Failed to attach sketch");
    if (!board.start())
        return Result::err("Failed to start internal runner");

    auto bv = board.view();
    auto gbv = make_ref<BoardView>();

    gbv->valid = true;
    gbv->view = bv;

    for (int i = 0; i < board_config->gpio_drivers.size(); ++i) {
        gbv->pins.append(GpioPin::FromNative(bv.pins[i]));
    }

    for (int i = 0; i < board_config->uart_channels.size(); ++i) {
        gbv->uart_channels.append(UartChannel::FromNative(bv.uart_channels[i]));
    }

    for (int i = 0; i < board_config->frame_buffers.size(); ++i) {
        gbv->frame_buffers[((Ref<BoardConfig::FrameBufferConfig>)board_config->frame_buffers[i])->key] =
            FrameBuffer::FromNative(bv.frame_buffers[i]);
    }

    m_view = gbv;
    m_sketch = sketch;

    sketch->connect("locked", this, "_on_sketch_locked");

    emit_status_changed();
    return Result::ok();
}

Ref<Result> Board::suspend() {
    if (!is_status(smce::Board::Status::running))
        return Result::err("Sketch is not running");
    if (!board.suspend())
        return Result::err("Failed to suspend internal runner");
    emit_status_changed();
    return Result::ok();
}

Ref<Result> Board::resume() {
    if (!is_status(smce::Board::Status::suspended))
        return Result::err("Sketch is not suspended");
    if (!board.resume())
        return Result::err("Failed to resume internal runner");
    emit_status_changed();
    return Result::ok();
}

Ref<Result> Board::poll() {

    if (stopped)
        return exit_code_res;

    if (auto [_, str] = board.runtime_log(); !str.empty()) {
        std::replace_if(
            str.begin(), str.end(), [](const auto& c) { return c == '\r'; }, '\t');
        log += str.data();
        str.clear();
        emit_signal("log_changed", log);
    }

    if (!is_active())
        return exit_code_res;

    board.tick();

    if (is_active()) {
        m_view->poll();
    }

    return exit_code_res;
}

Ref<Result> Board::stop() {
    if (is_status(smce::Board::Status::clean))
        return Result::err("Board has not run yet");

    if (stopped)
        return exit_code_res;

    poll();

    if (is_active())
        board.terminate();

    m_view->valid = false;
    m_view->emit_signal("invalidated");

    emit_status_changed();

    stopped = true;
    return exit_code_res;
}

int Board::get_status() { return static_cast<int>(board.status()); }

Ref<BoardView> Board::get_view() { return m_view; }

// When our sketch is locked we shoudn't touch it so simply stop.
// done in class to enforce it.
void Board::_on_sketch_locked(bool) { stop(); }