extends Node


func load_mods() -> void:
	var ext_mod_dir = Global.usr_dir_plus("mods")
	var local_mod_dir = "res://mods"
	
	for mod_pck in Util.ls(ext_mod_dir):
		if !ProjectSettings.load_resource_pack(ext_mod_dir.plus_file(mod_pck), true):
			continue
		
		print("Loaded mod pck: %s" % mod_pck)
	
	for mod in Util.ls(local_mod_dir):
		var path: String = local_mod_dir.plus_file(mod)
		
		if !ResourceLoader.exists(path, "GDScript"):
			continue

		var script = load(path)
		if ! is_instance_valid(script):
			continue
			
		var inst = script.new()
		
		if !_is_mod(inst):
			printerr("'%s' is not a valid mod" % mod)
			
			if ! (inst is Reference):
				inst.free()
			continue
		
		if inst is Node:
			inst.name = inst.mod_name
			add_child(inst)
		
		print("Initializing mod: %s" % inst.mod_name)
		inst.init(Global)


func _is_mod(ref) -> bool:
	if ! is_instance_valid(ref):
		return false
	var props = Util.get_custom_pops(ref)
	
	for prop in ["mod_name"]:
		if !props.has(prop):
			return false
	
	return true
