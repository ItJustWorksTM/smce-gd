#
#  Main.gd
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

class_name Main
extends Node

var universe := Universe.new()
var camera := ControllableCamera.new()

func _init(_env: EnvInfo):
	pass

func _ready():
	add_child(universe)
	add_child(camera)
	camera.current = true
	
	assert(universe.set_world_to("Test/Test"))
	camera.set_target_transform(universe.active_world_node.get_camera_starting_pos_hint())

func queue_compile():
	pass
