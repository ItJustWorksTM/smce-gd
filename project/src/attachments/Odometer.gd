#
#  Odometer.gd
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
func extern_class_name():
	return "Odometer"

onready var prev_pos: Vector3 = global_transform.origin
onready var velocity: Vector3 = Vector3.ZERO

export(NodePath) var _forward_reference
onready var forward_reference: Spatial = get_node_or_null(_forward_reference)

export(bool) var provides_direction = true
export(int, 100) var distance_pin = 99
onready var distance_back_pin = 100 + distance_pin
onready var speed_pin = 50 + distance_pin
export(int, 100) var direction_pin = 99

var total_distance: float = 0
var speed: float = 0
var forward: bool = true

var view = null setget set_view
var _traveled: float = 0

func set_view(_view: Node) -> void:
	if ! _view:
		return
		
	view = _view
	view.connect("validated", self, "_reset", [true])
	view.connect("invalidated", self, "_reset", [false])
	
	_reset(view.is_valid())


func _reset(psy: bool) -> void:
	view.write_analog_pin(distance_pin, 0)
	view.write_analog_pin(distance_back_pin, 0)
	view.write_analog_pin(speed_pin, 0)
	set_physics_process(psy)


func _ready():
	set_physics_process(false)
	if ! forward_reference:
		forward_reference = self


func _physics_process(delta):
	velocity = (global_transform.origin - prev_pos) * Vector3(1,0,1) / delta
	speed = sqrt(velocity.x * velocity.x + velocity.z * velocity.z) / 10 # ignore y axis speed for now
	
	_traveled += _distance_count() * 10
	
	var new_dist = int(_traveled)
	_traveled -= new_dist
	
	if new_dist > 0:
		view.write_analog_pin(distance_pin, view.read_analog_pin(distance_pin) + new_dist)
	elif new_dist < 0:
		view.write_analog_pin(distance_back_pin, view.read_analog_pin(distance_back_pin) + abs(new_dist))
	

	view.write_analog_pin(speed_pin, speed * 1000)
	view.write_digital_pin(direction_pin, forward)
	
	var fw_dist = view.read_analog_pin(distance_pin)
	var bw_dist = view.read_analog_pin(distance_back_pin)
	
	if provides_direction:
		total_distance = fw_dist - bw_dist
	else:
		total_distance = fw_dist + bw_dist
	

	prev_pos = global_transform.origin
	
	if ! view.is_valid():
		_reset(false)


func _distance_count() -> float:
	# TODO: disable on something
	if global_transform.origin.is_equal_approx(prev_pos):
		return 0.0
	
	var fwd: Vector3 = forward_reference.transform.basis.xform(Vector3.FORWARD)
	
	var forward_angle: float = velocity.normalized().dot(fwd.normalized())
	forward = forward_angle > 0
	
	var distance = (prev_pos * Vector3(1,0,1)).distance_to(global_transform.origin * Vector3(1,0,1))
	# Uncomment to take straightness into account
	# as sideways travel would normally not be detected by real odometers
	# untested though
	# distance *= abs(forward_angle)
	if forward:
		return distance
	return -distance


func name() -> String:
	if provides_direction:
		return "Directional Odometer"
	return "Directionless Odometer"


func visualize() -> Control:
	var visualizer = NodeVisualizer.new()
	visualizer.display_node(self, "visualize_content")
	return visualizer


func visualize_content() -> String:
	return "   Pins: %d,%d\n   Forward: %s\n   Speed: %.3f m/s\n   Total distance: %.3f m" % [distance_pin, direction_pin, str(forward), speed, total_distance / 100]
