
func err(msg = null):    return Result.new().set_err(msg)
func ok():    return Result.new().set_ok(null)

var res_dir := ProjectSettings.globalize_path("res://")

func setup_env() -> EnvInfo:
    var env_info = EnvInfo.new(res_dir.plus_file(".smcegd_home"))

    return env_info

func test_udd():

    var spec = BoardDeviceSpec.new() \
        .with_name("_TotallyOOP") \
        .with_atomic_u32("id") \
        .with_atomic_u32("value") \

    var device_config = BoardDeviceConfig.new()
    device_config.amount = 1
    device_config.spec = spec

    var config = BoardConfig.new()
    config.board_devices.append(device_config)

    var board = Board.new()
    var init_res = board.init(config)

    if init_res.is_err():
        return init_res

    var plugin = PluginManifest.new()
    plugin.name = "TotallyOOP"
    plugin.version = "1.0"
    plugin.needs_devices = ["_TotallyOOP"]
    plugin.uri = "file://" + res_dir.plus_file("tests/plugins/TotallyOOP")

    var sketch_config = SketchConfig.new()
    sketch_config.fqbn = "arduino:sam:arduino_due_x"    
    sketch_config.plugins = [plugin]
    sketch_config.genbind_devices = [spec]

    var sketch = Sketch.new()
    sketch.path = res_dir.plus_file("tests/sketches/udd")
    sketch.config = sketch_config

    var env := setup_env()
    var tc = Toolchain.new()
    var _tc_init_res = tc.init(env.smce_resources_dir)

    var log_reader = tc.log_reader()
    var compile_res = tc.compile(sketch)

    if !compile_res.is_ok():
        compile_res.set_err(str(compile_res.get_value()) + "\n" + str(env) + "\n" + str(log_reader.read()))
        return compile_res

    if !sketch.is_compiled():
        return err("Succesfully compiled but sketch does not report as such")

    var dynamic = board.get_view().board_devices[spec.name][0]
    dynamic.id = 42
    dynamic.value = 1

    board.start(sketch)

    yield(Engine.get_main_loop().create_timer(2), "timeout")

    if dynamic.value != 123:
        return err("value is %d required 123" % dynamic.value)


    return board.stop()
