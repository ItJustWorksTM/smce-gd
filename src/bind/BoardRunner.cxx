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

#include "bind/BoardRunner.hxx"
#include "bind/BoardView.hxx"

using namespace godot;

#define STR(s) #s
#define U(f)                                                                                                 \
    std::pair { STR(f), &BoardRunner::f }
#define R(f)                                                                                                 \
    std::pair { STR(f), &BoardRunner::fw_wrap<&smce::BoardRunner::f> }

void BoardRunner::_register_methods() {
    register_signal<BoardRunner>("status_changed");
    register_fns(R(reset), R(start), R(suspend), R(resume), U(terminate), U(configure), U(build), U(status),
                 U(emit_status), U(init_context), U(view), U(uart));
}

#undef STR
#undef R
#undef U

void BoardRunner::_init() { Godot::print("BoardRunner created"); }

std::optional<smce::BoardRunner>& BoardRunner::native() { return runner; }

bool BoardRunner::configure(String pp_fqbn) {
    if (!runner)
        return false;

    const auto fqbin_view = std::string_view{pp_fqbn.alloc_c_string(), static_cast<size_t>(pp_fqbn.length())};

    const auto config = smce::BoardConfig{
        .pins = {1},
        .gpio_drivers = {smce::BoardConfig::GpioDrivers{
            .pin_id = 1,
            .analog_driver =
                smce::BoardConfig::GpioDrivers::AnalogDriver{.board_read = true, .board_write = true}}},
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

        auto ret = runner->build(src, {});
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
    runner.emplace(exec_context);

    emit_status();

    return true;
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

void BoardRunner::emit_status() {
    if (runner)
        emit_signal("status_changed", static_cast<int>(runner->status()));
}

String BoardRunner::context() { return exec_context.resource_dir().c_str(); }

UartSlurper* BoardRunner::uart() { return uart_node; }
