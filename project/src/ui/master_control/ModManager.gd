#
#  ModManager.gd
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


func load_mods() -> void:
	var ext_mod_dir = Global.usr_dir_plus("mods")
	var local_mod_dir = "res://mods"
	
	var loaded_count := 0
	for mod_pck in Util.ls(ext_mod_dir):
		print("Found mod pck: %s" % mod_pck)
		if !ProjectSettings.load_resource_pack(ext_mod_dir.plus_file(mod_pck), true):
			print("Failed to load mod pck")
			continue
		loaded_count += 1
	
	var initialized_count := 0
	for mod in Util.ls(local_mod_dir):
		print("Initializing mod file: ", mod)
		var path: String = local_mod_dir.plus_file(mod)
		
		if !ResourceLoader.exists(path, "GDScript"):
			printerr("Mod file %s is not a valid script!" % path)
			continue

		var script = load(path)
		if ! is_instance_valid(script):
			printerr("Can not load mod file as GDScript")
			continue
		
		var inst = script.new()
		
		if !_is_mod(inst):
			printerr("'%s' is not a valid mod" % mod)
			
			if ! (inst is Reference):
				inst.free()
			continue
		
		print("Mod instance created, named %s" % inst.mod_name)
		
		if inst is Node:
			inst.name = inst.mod_name
			add_child(inst)
		
		inst.init(Global)
		
		initialized_count += 1
	
	if loaded_count != initialized_count:
		print("The amount of loaded mods differs from the amount of initialized mods!")


func _is_mod(ref) -> bool:
	if ! is_instance_valid(ref):
		return false
	var props = Util.get_custom_pops(ref)
	
	for prop in ["mod_name"]:
		if !props.has(prop):
			return false
	
	return true
