/*
 *  board->cxx
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
#include "types/bind/board_view/DynamicBoardDevice.hxx"
#include "types/bind/board_view/UartChannel.hxx"
#include "Board.hxx"

using namespace godot;

#define STR(s) #s
#define U(f)                                                                                                 \
    std::pair { STR(f), &Board::f }

void Board::_register_methods() {
    register_fns(U(init), U(start), U(suspend), U(resume), U(stop), U(get_status), U(get_view), U(poll),
                 U(log_reader), U(is_active));
}

#undef STR
#undef U

Board::Board()
    : board{std::make_shared<smce::Board>([&](int res) {
          exit_code = res;
          exit_code_res->set_err(exit_code);
          m_view->valid = false;
          m_view->emit_signal("invalidated");
      })} {}

void Board::_init() {
    m_view = make_ref<BoardView>();
    m_log_reader = make_ref<BoardLogReader>();
    m_log_reader->board = board;
}

smce::Board& Board::native() { return *board; }

Ref<Result> Board::init(Ref<BoardConfig> board_config) {
    if (!is_status(smce::Board::Status::clean))
        return Result::err("Board already in use");
    if (!board->configure(board_config->to_native()))
        return Result::err("Failed to configure board");
    if (!board->prepare())
        return Result::err("Failed to prepare board");

    auto bv = board->view();
    auto gbv = make_ref<BoardView>();

    gbv->valid = true;
    gbv->view = bv;

    for (int i = 0; i < board_config->gpio_drivers.size(); ++i) {
        auto info = static_cast<Ref<BoardConfig::GpioDriverConfig>>(board_config->gpio_drivers[i]);
        gbv->pins[info->pin] = GpioPin::from_native(info, bv.pins[i]);
    }

    for (int i = 0; i < board_config->uart_channels.size(); ++i) {
        auto info = static_cast<Ref<BoardConfig::UartChannelConfig>>(board_config->uart_channels[i]);
        gbv->uart_channels[i] = UartChannel::from_native(info, bv.uart_channels[i]);
    }

    for (int i = 0; i < board_config->frame_buffers.size(); ++i) {
        auto info = static_cast<Ref<BoardConfig::FrameBufferConfig>>(board_config->frame_buffers[i]);
        gbv->frame_buffers[info->key] = FrameBuffer::from_native(info, bv.frame_buffers[i]);
    }

    for (int i = 0; i < board_config->board_devices.size(); ++i) {
        auto info = static_cast<Ref<BoardConfig::BoardDeviceConfig>>(board_config->board_devices[i]);
        if (info.is_null()) {
            continue;
        }

        auto key = String{info->spec->to_native().name.data()};

        if (gbv->board_devices.has(key))
            continue;

        auto devices = Array{};

        for (size_t i = 0; i < info->amount; ++i) {
            devices.push_back(DynamicBoardDevice::create(info->spec, bv));
        }

        gbv->board_devices[key] = devices;
    }

    m_view = gbv;
    return Result::ok();
}

Ref<Result> Board::start(Ref<Sketch> sketch) {
    if (!sketch->is_compiled())
        return Result::err("Sketch is not compiled");
    if (!board->attach_sketch(sketch->native()))
        return Result::err("Failed to attach sketch");
    if (!board->start())
        return Result::err("Failed to start internal runner");

    // TODO: check if sketch board devices match the board config

    m_sketch = sketch;

    return Result::ok();
}

Ref<Result> Board::suspend() {
    if (!is_status(smce::Board::Status::running))
        return Result::err("Sketch is not running");
    if (!board->suspend())
        return Result::err("Failed to suspend internal runner");
    return Result::ok();
}

Ref<Result> Board::resume() {
    if (!is_status(smce::Board::Status::suspended))
        return Result::err("Sketch is not suspended");
    if (!board->resume())
        return Result::err("Failed to resume internal runner");
    return Result::ok();
}

Ref<Result> Board::poll() {

    if (stopped)
        return exit_code_res;

    if (!is_active())
        return exit_code_res;

    // Should cause side effects if sketch has crashed
    board->tick();

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

    if (is_active()) {
        board->terminate();
    }

    m_view->valid = false;
    m_view->emit_signal("invalidated");

    stopped = true;
    return exit_code_res;
}

int Board::get_status() { return static_cast<int>(board->status()); }

Ref<BoardView> Board::get_view() { return m_view; }

void BoardLogReader::_register_methods() { register_method("read", &BoardLogReader::read); }

Variant BoardLogReader::read() {
    if (auto [_, str] = board->runtime_log(); !str.empty()) {
        std::replace_if(
            str.begin(), str.end(), [](const auto& c) { return c == '\r'; }, '\t');
        auto ret = String{str.c_str()};
        str.clear();

        return ret;
    }
    return Variant{};
}
