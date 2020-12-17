/*
 *  EmulGlue.hxx
 *  Copyright 2020 ItJustWorksTM
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

#ifndef GODOT_SMCE_EMULGLUE_HXX
#define GODOT_SMCE_EMULGLUE_HXX

#include <atomic>
#include <filesystem>
#include <string>
#include <BoardData.hxx>
#include <BoardInfo.hxx>
#include <Godot.hpp>
#include <Label.hpp>
#include <Runtime.hxx>
#include <Source.hxx>
#include <VehicleConf.hxx>
#include <fmt/format.h>
#include <nameof.hpp>
#include <utility.hxx>
#include "util.hxx"
#include "BoardConf.hxx"
#include "Toolchain.hxx"
#include "VehicleConf.hxx"

namespace godot {

    class EmulGlue : public Node {
    GODOT_CLASS(EmulGlue, Node);
        std::atomic<bool> compile_done = false;
        smce::SketchRuntime ino_runtime{};
        std::optional<std::future<smce::CompilationResults>> compile_tr{};
        std::pair<BoardData, BoardInfo> board;

    public:
        static void _register_methods() {
#define STR(s) #s
#define R(f) std::pair { STR(f), &EmulGlue::f }
            constexpr auto register_fns = []<class... T>(std::pair<const char *, T>... func) {
                (register_method(func.first, func.second), ...);
            };
            register_fns(R(_process), R(_ready), R(has_board), R(compile), R(write_uart_n), R(get_uart_buf_n),
                         R(pause_board),
                         R(resume_board), R(reset_board), R(set_digital_n), R(get_digital_n), R(set_analog_n),
                         R(get_analog_n));
#undef R
#undef STR

            constexpr auto register_sig = [](auto... name) { (register_signal<EmulGlue>(name, Dictionary()), ...); };
            register_sig("board_started", "board_resumed", "board_paused", "board_paused", "board_stopped",
                         "board_reset");

            register_signal<EmulGlue>("compile_finished", "successful", GODOT_VARIANT_TYPE_BOOL, "message",
                                      GODOT_VARIANT_TYPE_STRING);
        }

        ~EmulGlue() { Godot::print("glue died"); }

        void _init();

        void _ready();

        void _process(float delta);

        bool compile(const String ino_path);

        bool has_board() const { return ino_runtime.is_initialized(); }

        bool write_uart_n(unsigned int bus, String msg);

        String get_uart_buf_n(unsigned int bus);

        void set_digital_n(unsigned int pin, bool value);

        Variant get_digital_n(unsigned int pin);

        void set_analog_n(unsigned int pin, uint8_t value);

        Variant get_analog_n(unsigned int pin);

        void pause_board() {
            ino_runtime.pause_now();
            emit_signal("board_paused");
        }

        void resume_board() {
            ino_runtime.resume();
            emit_signal("board_resumed");
        }

        void reset_board() {
            ino_runtime.clear();
            emit_signal("board_reset");
        }

    };

} // namespace godot

#endif //GODOT_SMCE_EMULGLUE_HXX
