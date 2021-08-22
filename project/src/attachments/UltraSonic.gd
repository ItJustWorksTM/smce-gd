#
#  UltraSonic.gd
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
class_name UltraSonic
func extern_class_name():
	return "UltraSonic"

export(int) var trigger_pin = 0
export(int) var echo_pin = 0

export(float, 0, 90, 0.1) var max_angle = 1.3 setget _update_angle
export(float, 0, 50, 0.1) var max_distance = 40 setget _update_distance
export(float, 0, 50, 0.1) var min_distance = 0.2
export(Array, int) var layers = [16, 4, 1] setget _update_layers

var raycasts = []
var _flat_raycasts = []

var color = []

var _view = null

var distance: float = 0

func set_view(view) -> void:
	if ! view:
		return
	
	_view = view
	
	view.connect("validated", self, "set_physics_process", [false])
	view.connect("invalidated", self, "set_physics_process", [true])
		
	set_physics_process(view.is_valid())


func _ready():
	randomize()
	_update_layers()
	set_physics_process(false)

func _update_distance(distance: float = max_distance) -> void:
	max_distance = distance
	for ray in _flat_raycasts:
		ray.cast_to = Vector3.FORWARD * max_distance


func _update_angle(angle: float = max_angle) -> void:
	max_angle = angle
	for i in range(raycasts.size()):
		var new_angle = deg2rad((raycasts.size() - i - (1 if i > 0 else 0)) * (max_angle / raycasts.size()))
		for j in range(raycasts[i].size()):
			raycasts[i][j].transform.basis = Basis()
			
			raycasts[i][j].rotate(Vector3(0,1,0), new_angle)
			raycasts[i][j].rotate(Vector3(0,0,1), PI/(raycasts[i].size() * 0.5) * j)


func _update_layers(_layers: Array = layers) -> void:
	layers = _layers
	for ray in _flat_raycasts:
		ray.queue_free()
	_flat_raycasts = []
	raycasts.resize(layers.size())
	color.resize(layers.size())
	
	for i in range(0, layers.size()):
		var arr = []
		arr.resize(layers[i])
		
		color[i] = Color(rand_range(0,1), rand_range(0,1), rand_range(0,1))
		
		for j in range(0, layers[i]):
			arr[j] = RayCast.new()
			_flat_raycasts.push_back(arr[j])
			add_child(arr[j])
			
			arr[j].enabled =  true
		raycasts[i] = arr
	
	_update_angle()
	_update_distance()


func _physics_process(delta):
	var i = 0
	var distances = PoolRealArray()
	for rays in raycasts:
		for ray in rays:
			if ray.is_colliding():
				var dist: float = global_transform.origin.distance_squared_to(ray.get_collision_point())
				if dist > min_distance:
					distances.push_back(dist)
					if ! DebugCanvas.disabled:
						DebugCanvas.add_draw(global_transform.origin, ray.get_collision_point(), color[i])
		i += 1
	var dist = 0
	if ! distances.empty():
		dist = sqrt(distances[rand_range(0, distances.size())])
	
	distance = dist
	_view.write_analog_pin(echo_pin, int(dist * 10))


func name() -> String:
	return "Ultrasonic Distance"


func visualize() -> Control:
	var visualizer = NodeVisualizer.new()
	visualizer.display_node(self, "visualize_content")
	return visualizer


func visualize_content() -> String:
	return "   Pins: %d,%d\n   Distance: %.3fm" % [trigger_pin, echo_pin, distance / 10]
