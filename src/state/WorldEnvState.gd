class_name WorldEnvState
extends Node3D

enum { VEHICLE_ACTIVE, VEHICLE_FROZEN }
enum { CAMERA_ORBITING, CAMERA_FREE }

var worlds := Track.array([])
var current_world := Track.value(-1)
var current_world_name := Track.combine_map(
    [worlds as Tracked, current_world],
    func(w, c): return w[c] if c >= 0 else ""
)

var camera_mode := Track.value(CAMERA_FREE)
var camera_following_label := Track.value(null)

var vehicles = Track.array([{ label = "test.ino#1", state = VEHICLE_FROZEN }])

var _camera := FreeCamera.new()
var _worlds := {
    "playground/Playground": load("res://assets/scenes/environments/playground/Playground.tscn"),
    "test_lab/TestLab": load("res://assets/scenes/environments/test_lab/TestLab.tscn")
}

var _current: Node3D

func follow_vehicle(label) -> void:
    camera_following_label.change(label)
    camera_mode.change(CAMERA_ORBITING)

func free_camera() -> void:
    camera_mode.change(CAMERA_FREE)

func change_world(world: String) -> void:
    if !(world in _worlds):
        return
    
    if _current:
        remove_child(_current)
        _current.queue_free()
    
    var w = _worlds[world].instantiate()
    
    add_child(w)
    _current = w

func _init():
    worlds.append_array(_worlds.keys())

func _ready() -> void:
    
    
    change_world("playground/Playground")
    
    _camera.position.y += 20
    _camera.rotation.x -= PI / 2
    add_child(_camera)
    await get_tree().create_timer(1.0).timeout
    _camera.target_rotation.x += PI / 2
    _camera.target_position.y -= 10
    _camera.target_position.z += 5
    

