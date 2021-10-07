#
#  ControllableCamera.gd
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


extends Spatial

var rot_x = 0
var rot_y = 0
var lookaround_speed = 0.01
var basis: Basis

export(int, 5, 100, 1) var scroll_limit_low = 5
export(int, 5, 100, 1) var scroll_limit_high = 20

export(int, 0, 90) var y_angle_limit = 20 setget set_y_angle_limit
var _y_angle_limit = 0
func set_y_angle_limit(limit: float) -> void:
	_y_angle_limit = range_lerp(limit, 0, 90, 0, PI/2)
	y_angle_limit = y_angle_limit
	_update_pos()

var _zoom = 9

var target: Spatial = null setget set_target, get_target
func set_target(trgt: Spatial) -> void:	
	if is_instance_valid(target):
		target = null
		set_process(false)
	
	if is_instance_valid(trgt):
		target = trgt
		set_process(true)
	
	_update_pos()


func get_target():
	return target if is_instance_valid(target) else null


func _unhandled_input(event: InputEvent) -> void:
	if FocusOwner.has_focus():
		return
	
	_zoom += 0.5 * int(event.is_action("scroll_down")) - int(event.is_action("scroll_up"))
	_zoom = clamp(_zoom, scroll_limit_low, scroll_limit_high)
	
	if event is InputEventMouseMotion and Input.is_action_pressed("mouse_left"):

		rot_x -= event.relative.x * lookaround_speed
		rot_y -= event.relative.y * lookaround_speed
		_update_pos()


func _update_pos():
	rot_y = clamp(rot_y, _y_angle_limit, PI - _y_angle_limit)
	if is_instance_valid(target):
		basis = Basis(Quat(Vector3(rot_y, rot_x, 0)))

func _ready():
	set_y_angle_limit(y_angle_limit)
	_update_pos()


func _process(delta: float) -> void:
	if ! is_instance_valid(target):
		set_process(false)
		return
	global_transform.origin = target.global_transform.origin + (target.global_transform.basis * basis).xform((Vector3.UP) * _zoom)
	look_at(target.global_transform.origin, Vector3.UP)



