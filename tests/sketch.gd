
var res_dir := ProjectSettings.globalize_path("res://")
func setup_env() -> EnvInfo:
    var env_info = EnvInfo.new(res_dir.plus_file(".smcegd_home"))

    return env_info


func test_load():
    var env = setup_env()
    var config := SketchConfig.new()

    config.fqbn = "arduino:sam:arduino_due_x"
    config.legacy_preproc_libs = ["MQTT@2.5.0", "WiFi@1.2.7", "Arduino_OV767X@0.0.2", "SD@1.2.4"]

    var manifest := PluginManifest.new()

    manifest.name = "Smartcar_shield"
    manifest.version = "7.0.1"
    manifest.uri = "https://github.com/platisd/smartcar_shield/archive/refs/tags/7.0.1.tar.gz"
    manifest.patch_uri = "file://" + env.library_patches_dir.plus_file("smartcar_shield")

    config.plugins.push_back(manifest)

    print(JSON.print(Reflect.inst2dict2_recursive(config), "  "))



    var loader = SketchLoader.new(config)

    var sketch: Sketch = loader.skload(res_dir.plus_file("tests/sketches/noop/noop.ino"))

    assert(sketch != null)

    print(sketch.get_source())


