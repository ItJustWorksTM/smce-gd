
func err(msg = null):    return Result.new().set_err(msg)
func ok():    return Result.new().set_ok(null)

var res_dir := ProjectSettings.globalize_path("res://")

func setup_env() -> EnvInfo:
    var env_info = EnvInfo.new(res_dir.plus_file(".smcegd_home"))
    
    return env_info

func test_initialize():
    var env := setup_env()
    
    var tc = Toolchain.new()
    
    var tc_init_res = tc.init(env.smce_resources_dir)
    
    if !tc_init_res.is_ok():
        return err()
    
    if !tc.is_initialized():
        return err()
    
    return ok()

func test_compile():
    var env := setup_env()
    
    var tc = Toolchain.new()
    
    var tc_init_res = tc.init(env.smce_resources_dir)
    print(tc_init_res)
    
    var sketch = Sketch.new()
    var sketch_path = res_dir.plus_file("tests/sketches/noop")
    
    var sketch_config = SketchConfig.new()
    sketch_config.fqbn = "arduino:sam:arduino_due_x"
    
    sketch.init(sketch_path, sketch_config)
    
    var log_reader = tc.log_reader()
    var compile_res = tc.compile(sketch)
    
    if !compile_res.is_ok():
        compile_res.set_err(str(compile_res.get_value()) + "\n" + str(env) + "\n" + str(log_reader.read()))
        return compile_res
    
    if !sketch.is_compiled():
        return err("Succesfully compiled but sketch does not report as such")
    
    return ok()



