#
#  Global.gd
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

onready var debug_canvas = DebugCanvas
onready var focus_owner = FocusOwner
onready var mod_manager = ModManager

var environments: Dictionary = {
	"playground/Playground": preload("res://src/environments/playground/Playground.tscn"),
}

var vehicles: Dictionary = {
	"RayCar": preload("res://src/objects/ray_car/RayCar.tscn"),
	"RayTank": preload("res://src/objects/ray_car/RayTank.tscn")
}

var user_dir: String = OS.get_user_data_dir() setget set_user_dir
var version: String = "unknown"

var _classes: Array = [
	AnalogRaycast, BrushedMotor,
	preload("res://src/attachments/Camera.gd"),
	preload("res://src/attachments/Gyroscope.gd"),
	preload("res://src/utilities/sensors/odometer/Odometer.gd"),
	RayCar, RayWheel, UltraSonic,
	preload("res://src/attachments/Odometer.gd"),
	ScreenBuffer]

var classes: Dictionary = {}

func usr_dir_plus(suffix: String) -> String:
	return "%s/%s" % [user_dir, suffix]


func set_user_dir(path: String) -> bool:
	var dir = Directory.new()
	
	if !dir.dir_exists(path) && !Util.mkdir(path):
		return false
	
	user_dir = path
	
	return true


func register_environment(name: String, scene: PackedScene) -> bool:
	if name == "" || !is_instance_valid(scene) || !scene.can_instance():
		return false
	
	environments[name] = scene
	print("Registered environment: %s" % name)
	return true


func register_vehicle(name: String, scene: PackedScene) -> bool:
	if name == "" || !is_instance_valid(scene) || !scene.can_instance():
		return false
	
	vehicles[name] = scene
	print("Registered vehicle: %s" % name)
	return true


func get_environment_names() -> Array:
	return environments.keys()


func get_environment(name: String) -> PackedScene:
	if environments.has(name):
		return environments[name]
	return null


func scan_named_classes(path: String) -> void:
	classes = _scan_named_classes(path)


func _scan_named_classes(path: String) -> Dictionary:
	var dir: Directory = Directory.new()
	dir.open(path)
	dir.list_dir_begin(true)
	
	var named_classes: Dictionary = {}
	
	for script in _classes:
		var instance: Object = script.new()
		if instance.has_method("extern_class_name"):
			named_classes[instance.call("extern_class_name")] = script
			print(instance.call("extern_class_name"))
		if ! (instance is Reference):
			instance.free()
	
	return named_classes
