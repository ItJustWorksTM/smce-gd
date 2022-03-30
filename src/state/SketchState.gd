class_name SketchState
extends Node

enum { BUILD_PENDING, BUILD_SUCCEEDED, BUILD_FAILED, BUILD_UNKNOWN }

var sketches := Track.array([])

var _user_config: UserConfigState

func _init(user_config: UserConfigState):
    self._user_config = user_config
    
func add_sketch(path: String):
    
    var config = self._user_config.get_config_for(path, "sketch")
    # TODO: ^^ observable?
    
    var plugin_defs = config["plugin_defs"]
    
    var sketch := Sketch.new()
    var skconfig = sketch.config
    skconfig.legacy_preproc_libs = PackedStringArray(config["arduino_libs"])
    skconfig.plugins = PackedStringArray(config["plugins"])
    sketch.source = path
    
    print(sketch.config)
    
    var manifest := ManifestRegistry.new()
    
    for plugin_name in plugin_defs:
        var def = plugin_defs[plugin_name]
        
        var plm = PluginManifest.new()
        plm.plugin_name = plugin_name
        plm.uri = def.get("uri", "")
        plm.patch_uri = def.get("patch_uri", "")
        plm.needs_devices = PackedStringArray(def.get("requires_devices", []))
        plm.defaults = def.get("defaults", 0)
        
        manifest.add_plugin(plm)
    
    manifest.add_board_device(GY50.smartcar_gyroscope())
    
    var state_obj = {
        sketch = sketch,
        registry = manifest,
        build_log = "",
        build_state = BUILD_UNKNOWN
    }
    sketches.push(state_obj)
    
    # might have changed since the announce LMAO
    var index = sketches.value().find(state_obj)
    
    return Result.new().set_ok(index)

func compile_sketch(sketch_id: int):
    var sketch = sketches.value_at(sketch_id)
    
    var tc = Toolchain.new()
    var tcres: Result = tc.initialize(sketch.registry, "/home/ruthgerd/.local/share/godot/app_userdata/SMCE-gd")
    
    assert(tcres.is_ok())
    
    var tc_log_reader = tc.log_reader()
    
    sketches.mutate_at(sketch_id, func(v):
        v.build_state = BUILD_PENDING
        return v
    )
    
    sketch = sketches.value_at(sketch_id)
    
    var cpres = tc.compile(sketch.sketch)
    var r = cpres.get_value()
    if cpres.is_err():
        printerr("Failed to compile sketch: ", cpres.get_value())
    
    sketches.mutate_at(sketch_id, func(v):
        if cpres.is_err(): v.build_state = BUILD_FAILED
        else: v.build_state = BUILD_SUCCEEDED
        v.build_log = tc_log_reader.read()
        return v
    )

func remove_sketch(sketch_id: int):
    pass

func register_plugin(sketch_id: int, plugin: PluginManifest):
    pass

func register_device(sketch_id: int, device: BoardDeviceSpecification):
    pass

# maybe the config provider should change these?
