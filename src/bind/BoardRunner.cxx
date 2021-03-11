/*
 *  BoardRunner.cxx
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

#include <array>
#include "bind/BoardRunner.hxx"
#include "bind/BoardView.hxx"

using namespace godot;

#define STR(s) #s
#define U(f)                                                                                                 \
    std::pair { STR(f), &BoardRunner::f }
#define R(f)                                                                                                 \
    std::pair { STR(f), &BoardRunner::fw_wrap<&smce::BoardRunner::f> }

void BoardRunner::_register_methods() {
    register_signal<BoardRunner>("status_changed", Dictionary{});
    register_signal<BoardRunner>("runtime_log", Dictionary{});
    register_signal<BoardRunner>("build_log", Dictionary{});
    register_fns(R(reset), R(start), R(suspend), R(resume), U(terminate), U(configure), U(build), U(status),
                 U(emit_status), U(init_context), U(view), U(uart), U(_physics_process), U(_notification),
                 U(get_exit_code));
}

#undef STR
#undef R
#undef U

void BoardRunner::_init() {
    Godot::print("BoardRunner created");
    set_physics_process(false);
}

void BoardRunner::_notification(int what) {
    if (what == Object::NOTIFICATION_PREDELETE) {
        Godot::print("BoardRunner terminate due to dtor");
        terminate();
    }
}

std::optional<smce::BoardRunner>& BoardRunner::native() { return runner; }

bool BoardRunner::configure(String pp_fqbn) {
    if (!runner)
        return false;

    const auto fqbin_view = std::string_view{pp_fqbn.alloc_c_string(), static_cast<size_t>(pp_fqbn.length())};

    const auto config =
        smce::BoardConfig{
            .pins = {0, 1, 2, 3, 4, 5, 12, 14, 13, 25, 26, 27, 34, 35, 36, 39, 85, 135, 86, 136, 205},
            .gpio_drivers =
                {
                    // Misc analog
                    {.pin_id = 0, .analog_driver = {{.board_read = true, .board_write = true}}},
                    {.pin_id = 1, .analog_driver = {{.board_read = true, .board_write = true}}},
                    {.pin_id = 2, .analog_driver = {{.board_read = true, .board_write = true}}},
                    {.pin_id = 3, .analog_driver = {{.board_read = true, .board_write = true}}},
                    {.pin_id = 4, .analog_driver = {{.board_read = true, .board_write = true}}},
                    {.pin_id = 5, .analog_driver = {{.board_read = true, .board_write = true}}},
                    // Left Brushed Motor
                    {.pin_id = 12, .digital_driver = {{.board_read = true, .board_write = true}}},
                    {.pin_id = 14, .digital_driver = {{.board_read = true, .board_write = true}}},
                    {.pin_id = 13, .analog_driver = {{.board_read = true, .board_write = true}}},
                    // Right Brushed Motor
                    {.pin_id = 25, .digital_driver = {{.board_read = true, .board_write = true}}},
                    {.pin_id = 26, .digital_driver = {{.board_read = true, .board_write = true}}},
                    {.pin_id = 27, .analog_driver = {{.board_read = true, .board_write = true}}},
                    // Left Odometer
                    {.pin_id = 35, .analog_driver = {{.board_read = true, .board_write = true}}},
                    {.pin_id = 34, .digital_driver = {{.board_read = true, .board_write = true}}},
                    {.pin_id = 85, .analog_driver = {{.board_read = true, .board_write = true}}},
                    {.pin_id = 135, .analog_driver = {{.board_read = true, .board_write = true}}},
                    // Right Odometer
                    {.pin_id = 36, .analog_driver = {{.board_read = true, .board_write = true}}},
                    {.pin_id = 39, .digital_driver = {{.board_read = true, .board_write = true}}},
                    {.pin_id = 86, .analog_driver = {{.board_read = true, .board_write = true}}},
                    {.pin_id = 136, .analog_driver = {{.board_read = true, .board_write = true}}},
                    // GY50
                    {.pin_id = 205, .analog_driver = {{.board_read = true, .board_write = true}}},

                },
            .uart_channels = {{}}};

    if (!runner->configure(fqbin_view, config))
        return false;

    view_node = BoardView::_new();
    view_node->view = runner->view();
    view_node->config = config;

    uart_node = UartSlurper::_new();
    uart_node->setup_bufs(runner->view());

    add_child(view_node);
    add_child(uart_node);

    emit_status();

    return true;
}

Ref<AnyTask> BoardRunner::build(String sketch_src) {
    return AnyTask::make_awaitable([&, sketch_src = std::move(sketch_src)] {
        if (!runner)
            return false;
        const auto path = sketch_src.utf8();
        const auto src = std::string_view{path.get_data(), static_cast<size_t>(path.length())};

        if (!stdfs::exists(src))
            return false;

        auto ret = runner->build(
            src, {.preproc_libs = {smce::SketchConfig::RemoteArduinoLibrary{"MQTT"}},
                  .complink_libs = {smce::SketchConfig::LocalArduinoLibrary{
                      exec_context.resource_dir() / "library_patches" / "smartcar_shield", "Smartcar shield"}}});
        if (ret)
            call_deferred("emit_status");
        return ret;
    });
}

bool BoardRunner::init_context(String context_path) {
    if (runner)
        return false;

    auto context = smce::ExecutionContext(context_path.utf8().get_data());

    if (!context.check_suitable_environment())
        return false;

    exec_context = context;
    runner.emplace(exec_context, [&](int code) {
        exit_code = code;
        emit_status();
        queue_free();
    });
    set_physics_process(true);
    emit_status();

    return true;
}

void BoardRunner::_physics_process() {

    auto& build_stream = runner->build_log();
    auto& runtime_stream = runner->runtime_log();

    std::array<char, 100> buf;

    const auto read_buf = [&](auto& stream) {
        size_t bytes_read = 0;
        if (auto* sb = stream.rdbuf()) {
            try {
                bytes_read = sb->sgetn(buf.data(), buf.size() - 1);
            } catch (...) {
            }
        }
        buf[bytes_read] = '\0';
        return bytes_read;
    };

    if (read_buf(runtime_stream) > 0) {
        emit_signal("runtime_log", String{buf.data()});
        std::cout << buf.data();
    }

    if (read_buf(build_stream) > 0) {
        emit_signal("build_log", String{buf.data()});
        std::cout << buf.data();
    }

    runner->tick();
}

BoardView* BoardRunner::view() { return view_node; }

bool BoardRunner::terminate() {
    if (!runner || !runner->terminate())
        return false;

    emit_status();

    // for now we just dont support reuse of the runner
    queue_free();

    return true;
}

int BoardRunner::status() { return runner ? static_cast<int>(runner->status()) : -1; }

int BoardRunner::get_exit_code() { return exit_code; }

void BoardRunner::emit_status() {
    if (runner)
        emit_signal("status_changed", static_cast<int>(runner->status()));
}

String BoardRunner::context() { return exec_context.resource_dir().c_str(); }

UartSlurper* BoardRunner::uart() { return uart_node; }
