#
#  ControllableCamera.gd
#  Copyright 2022 ItJustWorksTM
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

class_name LockedCam
extends CameraControllerBase

var rot_x = 0
var rot_y = 0
var lookaround_speed = 0.01
var basis: Basis = Basis.IDENTITY
var target: Spatial = null setget set_target, get_target

export(int, 5, 100, 1) var scroll_limit_low = 5
export(int, 5, 100, 1) var scroll_limit_high = 20

export(int, 0, 90) var y_angle_limit = 20 setget set_y_angle_limit
var _y_angle_limit = 0
var _zoom = 9

func _init(cam: Spatial, trgt: Spatial).(cam):
	set_target(trgt)
	set_y_angle_limit(y_angle_limit)
	_set_init_rot_angles()
	
func _set_init_rot_angles() -> void:
	var target_basis = target.global_transform.basis
	var camera_basis = cam.global_transform.basis
	
	var cross = target_basis.y.cross(camera_basis.z).normalized()
	var v = target_basis.x.normalized()
	var normal = target_basis.y.normalized()
	
	# Calculate clockwise rotation angles between vectors
	# in a 3D plane, with values between [-PI, PI] radians
	# https://stackoverflow.com/a/16544330
	var det = Basis(cross, v, normal).determinant()
	var x_angle = - atan2(det, cross.dot(v))
	var y_angle = target_basis.y.angle_to(camera_basis.z)
	
	rot_x = x_angle
	rot_y = y_angle
	_update_pos()

func set_y_angle_limit(limit: float) -> void:
	_y_angle_limit = range_lerp(limit, 0, 90, 0, PI/2)
	y_angle_limit = y_angle_limit
	_update_pos()


func set_target(trgt: Spatial) -> void:
	target = trgt
	_update_pos()


func get_target():
	return target if is_instance_valid(target) else null


func handle_event(event: InputEvent) -> void:
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


func cam_physics_process(_delta: float) -> Transform:
	if ! is_instance_valid(target):
		return cam.global_transform
	
	var new_pos_vec: Vector3 = (target.global_transform.basis * basis).xform(_zoom * Vector3.UP)
	var new_position: Vector3 = target.global_transform.origin + new_pos_vec

	var new_transform: Transform = Transform(cam.global_transform.basis, new_position)
	new_transform = new_transform.looking_at(target.global_transform.origin, Vector3.UP)
	
	return new_transform

	
