class_name SketchImpl


static func sketch_impl(user_config: UserConfigState): return func(c: Ctx):
    c.inherits(Node)
    
    var state = c.register_state(SketchState, SketchState.new())
    
    state.add_sketch = func(path: String):
        
        var config = user_config.get_config_for.call(path, "sketch")
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
        
        var state_obj = SketchState.StateObj.new()
        state_obj.sketch = sketch
        state_obj.registry = manifest
        state_obj.build_log = ""
        state_obj.build_state = SketchState.BUILD_UNKNOWN
        state.sketches.push(state_obj)
        
        # might have changed since the announce LMAO
        var index = state.sketches.value().find(state_obj)
        
        return Result.new().set_ok(index)

    state.compile_sketch = func(sketch_id: int):
        var sketch = state.sketches.value_at(sketch_id)
        
        var tc = Toolchain.new()
        var tcres: Result = tc.initialize(sketch.registry, "/home/ruthgerd/.local/share/godot/app_userdata/SMCE-gd")
        
        assert(tcres.is_ok())
        
        var tc_log_reader = tc.log_reader()
        
        state.sketches.mutate_at(sketch_id, func(v):
            v.build_state = SketchState.BUILD_PENDING
            return v
        )
        
        sketch = state.sketches.value_at(sketch_id)
        
        var cpres = tc.compile(sketch.sketch)
        var r = cpres.get_value()
        if cpres.is_err():
            printerr("Failed to compile sketch: ", cpres.get_value())
        
        state.sketches.mutate_at(sketch_id, func(v):
            if cpres.is_err(): v.build_state = SketchState.BUILD_FAILED
            else: v.build_state = SketchState.BUILD_SUCCEEDED
            v.build_log = tc_log_reader.read()
            return v
        )

    state.remove_sketch = func(sketch_id: int):
        pass

    state.register_plugin = func(sketch_id: int, plugin: PluginManifest):
        pass

    state.register_device = func(sketch_id: int, device: BoardDeviceSpecification):
        pass

