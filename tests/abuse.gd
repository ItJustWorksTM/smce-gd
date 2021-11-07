
func err(msg = null): return Result.new().set_err(msg)
func ok(): return Result.new().set_ok(null)

var res_dir := ProjectSettings.globalize_path("res://")

func setup_env() -> EnvInfo:
    var env_info = EnvInfo.new(res_dir.plus_file(".smcegd_home"))

    return env_info


func make_boards(n):
    var acc = []
    for __ in range(n):
        var board = Board.new()
        board.init(BoardConfig.new())
        acc.append(board)
    return acc

func test_abuse():

    var env := setup_env()
    var tc = Toolchain.new()
    var _tc_init_res = tc.init(env.smce_resources_dir)

    var sketch = Sketch.new()
    sketch.path = res_dir.plus_file("tests/sketches/abuse")

    var sketch_config = SketchConfig.new()
    sketch_config.fqbn = "arduino:sam:arduino_due_x"

    sketch.config = sketch_config

    var log_reader = tc.log_reader()
    var compile_res = tc.compile(sketch)

    if !compile_res.is_ok():
        compile_res.set_err(str(compile_res.get_value()) + "\n" + str(env) + "\n" + str(log_reader.read()))
        return compile_res

    if !sketch.is_compiled():
        return err("Succesfully compiled but sketch does not report as such")

    var running = []
    for board in make_boards(50):
        print(board.start(sketch))
        running.append(board)

    for __ in range(10):
        for board in running:
            print(board.suspend())
            yield(Engine.get_loop().create_timer(0.1), "timeout")

        for board in running:
            print(board.resume())
            yield(Engine.get_loop().create_timer(0.1), "timeout")

    for board in running:
        print(board.stop())


