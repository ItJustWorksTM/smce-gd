class_name SketchState
extends Node

enum { BUILD_PENDING, BUILD_SUCCEEDED, BUILD_FAILED, BUILD_UNKNOWN }

# TODO: observe buffer (for detecting state transition)

var _id: int = 0
var sketches = TrackedVec.new()

var _user_config: UserConfigState

func _init(user_config: UserConfigState):
	self._user_config = user_config
	
func add_sketch(path: String):
	
	var config = self._user_config.get_config_for(path, "sketch")
	# TODO: ^^ observable?
	
	var plugin_defs = config["plugin_defs"]
	
	var sketch := Sketch.new()
	var sk_conf := SketchConfig.new()
	sk_conf.legacy_preproc_libs = PackedStringArray(config["arduino_libs"])
	sk_conf.plugins = PackedStringArray(config["plugins"])
	sketch.config = sk_conf
	
	var manifest := ManifestRegistry.new()
	
	for plugin_name in plugin_defs:
		var def = plugin_defs[plugin_name]
		
		var plm = PluginManifest.new()
		plm.plugin_name = plugin_name
		plm.uri = def.get("patch_uri", "")
		plm.patch_uri = def.get("patch_uri", "")
		plm.needs_devices = PackedStringArray(def.get("requires_devices", []))
		
		manifest.add_plugin(plm)
	
	sketches.push({
		id = self._id,
		sketch = sketch,
		registry = manifest
	})
	
	_id += 1
	return Result.new().set_ok(null)

func compile_sketch(sketch_id: int):
	
	var tc = Toolchain.new()
	var tcres: Result = tc.initialize(registry, "/home/ruthgerd/.local/share/godot/app_userdata/SMCE-gd")
	
	assert(tcres.is_ok())
	
	var tc_log_reader = tc.log_reader()
	
	var cpres = tc.compile(sketch)
	var r = cpres.get_value()
	if cpres.is_err():
		print(r)
		print(tc_log_reader.read())
		assert(false)
	pass

func remove_sketch(sketch_id: int):
	pass

func register_plugin(sketch_id: int, plugin: PluginManifest):
	pass

func register_device(sketch_id: int, device: BoardDeviceSpecification):
	pass

# maybe the config provider should change these?
