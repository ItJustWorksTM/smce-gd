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
	
	var next: String = dir.get_next()
	while next != "":
		if dir.dir_exists(path.plus_file(next)):
			Util.merge_dict_shallow(named_classes, _scan_named_classes(path.plus_file(next)))
		
		var ext: String = next.get_extension()
		if ext == "gd" || ext == "gdns":
			var script = load(path.plus_file(next))
			var instance: Object = script.new()
			if instance.has_method("extern_class_name"):
				named_classes[instance.call("extern_class_name")] = script
			if ! (instance is Reference):
				instance.free()
		
		next = dir.get_next()
	
	return named_classes
