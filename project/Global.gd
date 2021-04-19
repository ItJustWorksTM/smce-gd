extends Node

onready var debug_canvas = DebugCanvas
onready var focus_owner = FocusOwner
onready var mod_manager = ModManager

var environments: Dictionary = {
	"playground/Playground": preload("res://src/environments/playground/Playground.tscn"),
}

var user_dir: String = OS.get_user_data_dir() setget set_user_dir
var version: String = "unknown"


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


func get_environment_names() -> Array:
	return environments.keys()

func get_environment(name: String) -> PackedScene:
	if environments.has(name):
		return environments[name]
	return null
	
