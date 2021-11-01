#
#  Observable.gd
#  Copyright 2021 ItJustWorksTM
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

class_name ControllableCamera
extends Camera

var smoothing: float = 0.3
var movement_speed: float = 0.2
var drag_sensitivity: float = 0.01

var target_rotation: Quat
var target_position: Vector3

func set_target_transform(transform: Transform):
    target_rotation = transform.basis
    target_position = transform.origin

var dragging: bool = false

var _rot := Vector3.ZERO

# TODO: implement orbit camera around target spatial node
var target: Spatial = null setget set_target, get_target

func set_target(_target: Spatial): target = _target
func get_target() -> Spatial: return null
func has_target() -> bool: return is_instance_valid(get_target())

func _ready():
    target_position = global_transform.origin
    target_rotation = global_transform.basis

func to_deg(fuck: Vector3):
    return Vector3(rad2deg(fuck.x),rad2deg(fuck.y),rad2deg(fuck.z))

func _unhandled_input(event: InputEvent):
    if event is InputEventMouseMotion:
        if dragging:
            var relative_drag = Vector3(event.relative.y, event.relative.x, 0) * drag_sensitivity
            if has_target():
                _rot -= relative_drag
                var lim = range_lerp(20, 0, 90, 0, PI/2)
                _rot.y = clamp(_rot.y, lim, PI - lim)

                target_rotation = Basis(Quat(_rot))
            else:
                target_rotation.set_euler(target_rotation.get_euler() - relative_drag)
            get_tree().set_input_as_handled()

    if event.is_action_pressed("mouse_left"):
        dragging = true
        get_tree().set_input_as_handled()

    if event.is_action_released("mouse_left"):
        dragging = false
        get_tree().set_input_as_handled()


func _poll_input() -> Vector3:
    var d := Input.get_action_strength("camera_backward") - Input.get_action_strength("camera_forward")
    var b := Input.get_action_strength("camera_right") - Input.get_action_strength("camera_left")
    var u :=  Input.get_action_strength("camera_up") - Input.get_action_strength("camera_down")

    var input_vec := Vector3(b,u,d)
    var movement := global_transform.basis.xform(Vector3(input_vec.x, 0, input_vec.z))
    movement.y += input_vec.y

    return movement * movement_speed


# TODO: use delta along with the smoothing
func _process(_delta):

    var target_rotation_euler := target_rotation.get_euler()
    target_rotation_euler.x = clamp(target_rotation_euler.x, deg2rad(-89), deg2rad(89))
    target_rotation_euler.z = 0
    target_rotation.set_euler(target_rotation_euler)


    if has_target():
        print("what the dog doing")
        target_position = get_target().global_transform.origin + (get_target().global_transform.basis * Basis(target_rotation)).xform((Vector3.UP) * 9)
        # Transform(target_rotation, target_position).looking_at(get_target())
    else:
        target_position += _poll_input()

    global_transform.origin = lerp(global_transform.origin, target_position, smoothing)
    transform.basis = Basis(Quat(transform.basis).slerp(target_rotation, smoothing))
    transform.basis = Quat(transform.basis.get_euler() * Vector3(1,1,0))



func _notification(what):
    if what == NOTIFICATION_PREDELETE && has_target():
        target.free()
