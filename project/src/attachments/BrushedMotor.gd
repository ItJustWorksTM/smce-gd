#
#  BrushedMotor.gd
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

extends Node
class_name BrushedMotor
func extern_class_name():
	return "BrusedMotor"

export(int, 100) var forward_pin = 0
export(int, 100) var backward_pin = 0
export(int, 100) var enable_pin = 0

var view = null setget set_view

var speed: float = 0
var direction: int = 0

func set_view(_view: Node) -> void:
	if ! _view:
		return
	
	view = _view
	view.connect("validated", self, "set_physics_process", [true])
	set_physics_process(view.is_valid())


func set_pins(ebl: int, fwd: int, bwd: int) -> void:
	enable_pin = ebl
	forward_pin = fwd
	backward_pin = bwd


func get_speed() -> float:
	return speed


func _ready() -> void:
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	var abs_speed = view.read_analog_pin(enable_pin)
	var forward = view.read_digital_pin(forward_pin)
	var backward = view.read_digital_pin(backward_pin)
	direction = int(forward) - int(backward)
	
	speed = (abs_speed / 255.0) * direction
	if ! view.is_valid():
		set_physics_process(false)


func name() -> String:
	return "BrushedMotor"


func visualize() -> Control:
	var visualizer = NodeVisualizer.new()
	visualizer.display_node(self, "visualize_content")
	return visualizer


var vs_dir: Array = ["None", "Forward", "Backward"]
func visualize_content() -> String:
	return "   Pins: %d,%d,%d\n   Throttle: %s \n   Direction: %s" % [forward_pin, backward_pin, enable_pin, str(int(abs(speed) * 100)) + '%',  vs_dir[direction]]
