#
#  AnalogRaycast.gd
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

extends RayCast
class_name AnalogRaycast
func extern_class_name():
	return "AnalogRaycast"

export(int, 100) var pin = 0
export(float) var min_distance = 0
export(float) var max_distance = 4

var view = null setget set_view

var distance: float = 0

func set_view(_view: Node) -> void:
	if ! _view:
		return
	
	view = _view
	
	view.connect("validated", self, "set_physics_process", [true])
	view.connect("invalidated", self, "set_physics_process", [false])
	
	set_physics_process(true)


func _ready() -> void:
	enabled = true
	
	cast_to = transform.basis.xform(Vector3.FORWARD) * max_distance
	set_physics_process(false)


func _physics_process(_delta: float):
	var dist = 0 # if not coliding 0 is reported
	if is_colliding():
		var hit = get_collision_point()
		dist =  global_transform.origin.distance_to(get_collision_point())
	
	if dist < min_distance:
		dist = 0
	
	distance = dist
	view.write_analog_pin(pin, int(dist * 10))
	_draw_debug()


func _draw_debug() -> void:
	if ! DebugCanvas.disabled:
		var pos = global_transform.origin
		DebugCanvas.add_draw(pos, pos + global_transform.basis.xform(cast_to))
		if is_colliding():
			DebugCanvas.add_draw(pos, get_collision_point(), Color.red)


func visualize() -> Control:
	var visualizer = NodeVisualizer.new()
	visualizer.display_node(self, "visualize_content")
	return visualizer


func visualize_content() -> String:
	return "   Pin: %d\n   Distance: %.3fm" % [pin, distance / 10]
