class_name WorldEnvState
extends Object

enum { CAMERA_ORBITING, CAMERA_FREE }

# state
var worlds := Cx.array([])
var current_world := Cx.value(-1)
var current_world_name := Cx.combine_map(
    [worlds as Tracked, current_world],
    func(w, c): return w[c] if c >= 0 else ""
)

var current_world_node := Cx.value(null)

var camera_following_node := Cx.value(null)
var camera_mode := Cx.map(camera_following_node, func(f): CAMERA_FREE if f == null else CAMERA_ORBITING)

# actions
var register_world := func(world_name, world): pass
var change_world := func(to_world): pass
