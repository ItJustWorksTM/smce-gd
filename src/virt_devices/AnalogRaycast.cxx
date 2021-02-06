#include "core/Math.hpp"
#include "virt_devices/AnalogRaycast.hxx"

using namespace godot;

void AnalogRaycast::_register_methods() {
    register_method("_physics_process", &AnalogRaycast::_physics_process);
    register_method("_on_view_invalidated", &AnalogRaycast::_on_view_invalidated);
    register_method("set_boardview", &AnalogRaycast::set_boardview);
}

void AnalogRaycast::_init() {
    set_physics_process(false);
    set_enabled(false);
}

void AnalogRaycast::_physics_process(float delta) {
    if (!is_colliding() || !board_view)
        return;

    const auto& pos = get_global_transform().get_origin();
    const auto point = get_collision_point();

    auto* debug = get_node("/root/DebugCanvas");
    if (!debug->get("disabled")) {
        debug->call("add_draw", pos, point, Color{0, 1, 0});
    }

    std::uint16_t dist = pos.distance_to(point) * 100;
    board_view->native().pins[1].analog().write(dist);
}

void AnalogRaycast::set_boardview(BoardView* view) {
    if (!view)
        return;
    view->connect("tree_exiting", this, "_on_view_invalidated");
    board_view = view;
    set_physics_process(true);
    set_enabled(true);
}

void AnalogRaycast::_on_view_invalidated() {
    board_view = nullptr;
    set_enabled(false);
    set_physics_process(false);
}
