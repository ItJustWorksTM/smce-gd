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

		var inst = load(path).new()
		
		if !_is_mod(inst) || !(inst is Reference):
			printerr("'%s' is not a valid mod" % mod)
			continue
		
		print("Initializing mod: %s" % inst.mod_name)
		inst.init(Global)


func _is_mod(ref: Reference) -> bool:
	var props = Util.get_custom_pops(ref)
	
	for prop in ["mod_name"]:
		if !props.has(prop):
			return false
	
	return true
