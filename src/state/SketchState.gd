class_name SketchState extends Node

enum { BUILD_PENDING, BUILD_SUCCEEDED, BUILD_FAILED, BUILD_UNKNOWN }

var sketches := Cx.array([])

var c: Ctx
var user_config: UserConfigState; var hardware_state: HardwareState

func add_sketch(source: String):
    var conf = user_config.g(Cx.value(source))
    
    var info = Cx.combine_map(
        [conf as Tracked, hardware_state.registered_hardware as Tracked],
        func(conf: Dictionary, hardware: Dictionary):
            # TODO: somehow put this deserialization into the config state?
            var sk_usr_conf = conf["sketch"]
            var sk_conf = SketchConfig.new()
            var registry = ManifestRegistry.new()

            sk_conf.legacy_preproc_libs = PackedStringArray(sk_usr_conf["arduino_libs"])
            
            var plugin_defs = sk_usr_conf.get("plugin_defs", [])
            for plugin_name in plugin_defs:
                var def = plugin_defs[plugin_name]
                
                var plm = PluginManifest.new()
                plm.plugin_name = plugin_name
                plm.uri = def.get("uri", "")
                plm.patch_uri = def.get("patch_uri", "")
                plm.needs_devices = PackedStringArray(def.get("requires_devices", []))
                plm.defaults = def.get("defaults", 0)
                
                sk_conf.plugins += PackedStringArray([plugin_name])
                
                registry.add_plugin(plm)
            
            
            var required_hardware = sk_usr_conf["hardware"]
            var already = {}
            for fu in required_hardware.values():
                if fu.type in hardware && !(fu.type in already):
                    var shi = hardware[fu.type]
                    for device in shi.devices.values():
                        registry.add_board_device(device)
                    already[fu.type] = null
            
            return { source = source, sk_conf = sk_conf, registry = registry,
                rt_resources = sk_usr_conf.rt_resources, hardware = hardware, req_hardware = sk_usr_conf.hardware }
    )
    
    
    var sketch = Sketch.new()
    sketch.source = info.value().source
    sketch.config = info.value().sk_conf
    var alias = sketch.config
    print()
    var sketch_s = Cx.value({ handle = sketch, state = SketchState.BUILD_UNKNOWN, log = "", build_error = null })
    
    self.sketches.push({info = info, sketch = sketch_s})
    
#    c.on(info.changed, func(w,h):
#        assert("TODO")
#    )
    
    return self.sketches.size()

func compile_sketch(index: int):
    var comb = self.sketches.value_at(index)
    var info = comb.info
    var native = comb.sketch
    var res = SketchState.compile_async(native.value().handle, info.value().registry, info.value().rt_resources)
    
    native.mutate(func(v):
        v.handle = null
        v.state = SketchState.BUILD_PENDING
        v.log = ""
        return v
    )
    
    c.child(func(c):
        c.inherits(Node)
        c.on(res.res.changed, func(w,h):
            var val = res.res.value()
            if val.sketch != null:
                res.log.poll()
                var build_result = val.res
                print("compile done: ", build_result.get_value())
                native.mutate(func(v):
                    v.handle = val.sketch
                    v.state = SketchState.BUILD_SUCCEEDED
                    if val.res.is_err():
                        v.state = SketchState.BUILD_FAILED
                        v.build_error = val.res.get_value()
                    return v
                )
                c.node().queue_free()
        )
        c.on(res.log.changed, func(w,h):
            native.mutate(func(v):
                v.log = res.log.value()
                return v
            )
        )            
    )

func remove_sketch(index: int):
    pass

func _init(user_config: UserConfigState, hardware_state: HardwareState):
    self.user_config = user_config
    self.hardware_state = hardware_state

func _ctx_init(c: Ctx):
    c.register_as_state()
    self.c = c

static func compile_async(sketch: Sketch, registry: ManifestRegistry, resource_dir: String):
    var tc = Toolchain.new()
    var tcres = Cx.value({ res = null, sketch = null })

    var res = tc.initialize(registry, resource_dir)
    
    var build_log = Cx.poll((func(last, log):
        var read = log.read() if log != null else ""
        if read != null && read != "":
            last.value += read
            return last.value
        return Tracked.Keep
    ).bind(RefCountedValue.new(""), tc.log_reader()))
    
    if res.is_ok():
        Future.new().start((func(tc, sketch):
            return { res = tc.compile(sketch), sketch = sketch }
        ).bind(tc, sketch)).connect(tcres.change)
    else:
        tcres.change.call_deferred({ res = res, sketch = sketch })
    
    return { res = tcres, log = build_log }
