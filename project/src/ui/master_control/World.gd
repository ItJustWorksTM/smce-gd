#
#  World.gd
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

var world_name = null
var world: Spatial = null

var debug_car: Spatial = null

onready var ctl_cam: ControllableCamera = $Camera

func get_spawn_position(hint = ""):
	if world.has_method("get_spawn_position"):
		return world.get_spawn_position(hint)
	return Transform(Basis(), Vector3(0,3,0))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_car_spawn"):
		if is_instance_valid(debug_car):
			debug_car.queue_free()
			return
		debug_car = load("res://src/objects/ray_car/RayCar.tscn").instance()
		debug_car.global_transform = get_spawn_position("debug_vehicle")
		add_child(debug_car)
	
	if event.is_action_pressed("debug_car_cam") and debug_car:
		if ctl_cam.locked == debug_car:
			ctl_cam.free_cam()
		else:
			ctl_cam.lock_cam(debug_car)


func _ready() -> void:
	DebugCanvas.disabled = true


func load_world(scene: PackedScene) -> bool:
	yield(get_tree(), "idle_frame")
	var instance = scene.instance()
	if is_instance_valid(instance):
		yield(clear_world(), "completed")
		
		add_child(instance)
		world = instance
		
		if world.has_method("init_cam_pos"):
			ctl_cam.set_cam_position(world.init_cam_pos())
		else:
			ctl_cam.set_cam_position()
		
		return true
	return false


func clear_world() -> void:
	yield(get_tree(), "idle_frame")
	if is_instance_valid(world):
		world.queue_free()
		
		if world.is_inside_tree():
			yield(world, "tree_exited")


func to_dict() -> Dictionary:
	return { "environment": world_name }
