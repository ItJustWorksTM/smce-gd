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

void BoardRunner::_register_methods() {
    register_signals<BoardRunner>("initialized", "configured", "building", "built", "started",
                                  "suspended_resumed", "stopped", "cleaned", "build_log", "runtime_log");

    register_fns(U(init), U(reset), U(start), U(suspend), U(resume), U(terminate), U(configure), U(build),
                 U(status), U(view), U(uart), U(_physics_process), U(on_build_completed), U(set_free));
}

#undef STR
#undef U

BoardRunner::~BoardRunner() {
    if (building)
        Godot::print("Warning: BoardRunner destroyed while still building");
}

void BoardRunner::_init() {
    Godot::print("BoardRunner created");

    view_node = BoardView::_new();
    uart_node = UartSlurper::_new();
    add_child(view_node);
    add_child(uart_node);

    set_physics_process(false);
}

std::optional<smce::BoardRunner>& BoardRunner::native() { return runner; }

Ref<GDResult> BoardRunner::init(String context_path) {
    if (runner)
        return GDResult::err("BoardRunner already initialized");

    ctx_path = std_str(context_path);

    auto context = smce::ExecutionContext{ctx_path};

    if (!context.check_suitable_environment())
        return GDResult::err("Unsuitable environment");

    exec_context = context;
    runner.emplace(exec_context, [&](int code) {
        emit_signal("stopped", code);
        view_node->set_view({});
        uart_node->set_view(view_node->native());
    });

    emit_signal("initialized");
    set_physics_process(true);

    return GDResult::ok();
}

Ref<GDResult> BoardRunner::configure(String pp_fqbn, BoardConfig* board_config) {
    if (!board_config)
        return GDResult::err("Invalid BoardConfig");

    fqbin = std_str(pp_fqbn);
    bconfig = board_config->to_native();

    return reconfigure();
}

Ref<GDResult> BoardRunner::reconfigure() {
    if (!runner)
        return GDResult::err("BoardRunner not initialized");
    if (runner->status() != smce::BoardRunner::Status::clean)
        return GDResult::err("BoardRunner not clean");
    if (!runner->configure(fqbin, bconfig))
        return GDResult::err("Failed to configure internal runner");

    view_node->set_view(runner->view());
    uart_node->set_view(runner->view());

    emit_signal("configured");

    return GDResult::ok();
}

Ref<AnyTask> BoardRunner::build(String sketch_src) {
    building = true;
    emit_signal("building");

    auto ret = AnyTask::make_awaitable([&, sketch_src = stdfs::path{std_str(sketch_src)}] {
        if (!runner)
            return GDResult::err("BoardRunner not initialized");

        if (!stdfs::exists(sketch_src))
            return GDResult::err("Sketch file does not exist");

        Godot::print("Async build starting");
        auto build_res = runner->build(
            sketch_src,
            {.preproc_libs = {smce::SketchConfig::RemoteArduinoLibrary{"MQTT"},
                              smce::SketchConfig::RemoteArduinoLibrary{"WiFi"}},
             .complink_libs = {smce::SketchConfig::LocalArduinoLibrary{
                 exec_context.resource_dir() / "library_patches" / "smartcar_shield", "Smartcar shield"}}});
        Godot::print("Async build completed");

        if (!build_res)
            return GDResult::err("Sketch failed to compile");

        return GDResult::ok();
    });

    ret->connect("completed", this, "on_build_completed");

    return ret;
}

void BoardRunner::on_build_completed(Ref<GDResult> result) {
    building = false;
    emit_signal("built", result);
    if (queued_free)
        queue_free(), Godot::print("Warning: BoardRunner queued to be freed on build complete");
}

Ref<GDResult> BoardRunner::start() {
    if (!runner)
        return GDResult::err("BoardRunner not initialized");
    if (runner->status() != smce::BoardRunner::Status::built)
        return GDResult::err("Sketch has not been built");
    if (!runner->start())
        return GDResult::err("Failed to start internal runner");
    emit_signal("started");
    return GDResult::ok();
}

Ref<GDResult> BoardRunner::suspend() {
    if (!runner)
        return GDResult::err("BoardRunner not initialized");
    if (runner->status() != smce::BoardRunner::Status::running)
        return GDResult::err("Sketch is not running");
    if (!runner->suspend())
        return GDResult::err("Failed to suspend internal runner");
    emit_signal("suspended_resumed", true);
    return GDResult::ok();
}

Ref<GDResult> BoardRunner::resume() {
    if (!runner)
        return GDResult::err("BoardRunner not initialized");
    if (runner->status() != smce::BoardRunner::Status::suspended)
        return GDResult::err("Sketch is not suspended");
    if (!runner->resume())
        return GDResult::err("Failed to resume internal runner");
    emit_signal("suspended_resumed", false);
    return GDResult::ok();
}

Ref<GDResult> BoardRunner::reset(bool auto_configure) {
    if (!runner)
        return GDResult::err("BoardRunner not initialized");
    if (building)
        return GDResult::err("Sketch is still building");
    if (!runner->reset())
        return GDResult::err("Sketch is still running");

    view_node->set_view({});
    uart_node->set_view(view_node->native());

    emit_signal("cleaned");

    if (auto_configure)
        if (auto res = reconfigure(); !res->is_ok())
            return res;

    return GDResult::ok();
}

void BoardRunner::_physics_process() {

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

    if (building) {
        auto& build_stream = runner->build_log();
        if (read_buf(build_stream) > 0) {
            emit_signal("build_log", String{buf.data()});
            std::cout << buf.data();
        }
    }

    if (runner->status() == smce::BoardRunner::Status::running ||
        runner->status() == smce::BoardRunner::Status::suspended) {
        auto& runtime_stream = runner->runtime_log();
        if (read_buf(runtime_stream) > 0) {
            emit_signal("runtime_log", String{buf.data()});
            std::cout << buf.data();
        }
    }

    runner->tick();
}

Ref<GDResult> BoardRunner::terminate() {
    if (!runner)
        return GDResult::err("BoardRunner not initialized");
    if (building)
        return GDResult::err("Sketch is still building");
    if (!runner->terminate())
        return GDResult::err("Failed to terminate internal runner");

    view_node->set_view({});
    uart_node->set_view(view_node->native());

    emit_signal("stopped", 0);
    return GDResult::ok();
}

void BoardRunner::set_free() {
    queued_free = true;
    if (building)
        return Godot::print("Warning: BoardRunner queued to be freed while still building");
    queue_free();
}

int BoardRunner::status() { return runner ? static_cast<int>(runner->status()) : -1; }

String BoardRunner::context() { return exec_context.resource_dir().c_str(); }

UartSlurper* BoardRunner::uart() { return uart_node; }

BoardView* BoardRunner::view() { return view_node; }
