#
#  FreeCam.gd
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

extends CameraControllerBase

var lookaround_speed = 0.01

export(int, 0, 90) var y_angle_limit = 20 setget set_y_angle_limit
var _y_angle_limit = 0
var rot_x = 0
var rot_y = 0
var next_position: Transform

func _init(cam: Camera).(cam):
	next_position = cam.global_transform
	rot_x = cam.global_transform.basis.get_euler().y
	rot_y = cam.global_transform.basis.get_euler().x
	_update_pos()

func set_y_angle_limit(limit: float) -> void:
	_y_angle_limit = range_lerp(limit, 0, 90, 0, PI/2)
	y_angle_limit = y_angle_limit


func handle_event(event) -> void:
	if event is InputEventMouseMotion and Input.is_action_pressed("mouse_left") and ! FocusOwner.has_focus():
		rot_x -= event.relative.x * lookaround_speed
		rot_y -= event.relative.y * lookaround_speed
		_update_pos()


func _update_pos():
	rot_y = clamp(rot_y, _y_angle_limit - PI/2, PI/2 - _y_angle_limit)
	next_position.basis = Basis(Quat(Vector3(rot_y, rot_x, 0)))

func cam_physics_process(delta: float) -> Transform:	
	var d = Input.get_action_strength("backward") - Input.get_action_strength("forward")
	var b = Input.get_action_strength("right") - Input.get_action_strength("left")
	var u = Input.get_action_strength("up") - Input.get_action_strength("down")
	var new = Vector3(b, 0, d) / 3
	var up = Vector3(0, u, 0) / 3
	
	next_position.origin += next_position.basis * new
	next_position.origin += up
	return next_position
	

