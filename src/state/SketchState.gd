class_name SketchState
extends Object

enum { BUILD_PENDING, BUILD_SUCCEEDED, BUILD_FAILED, BUILD_UNKNOWN }

class StateObj:
    var sketch: Sketch
    var registry: ManifestRegistry
    var build_log: String = ""
    var build_state = BUILD_UNKNOWN

var sketches := Cx.array([])
    
var add_sketch = func(path: String): pass
var compile_sketch = func(sketch_id: int): pass
var remove_sketch = func(sketch_id: int): pass
var register_plugin = func(sketch_id: int, plugin: PluginManifest):pass
var register_device = func(sketch_id: int, device: BoardDeviceSpecification): pass

# maybe the config provider should change these?
