#
#  Main.gd
#  Copyright 2021 ItJustWorksTM
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

class_name Main
extends Node

# actually global
var universe := Universe.new()
var camera := ControllableCamera.new()

var sketch_builder: SketchBuilder
var sketch_loader: SketchLoader

var entities = []

enum BoardState { READY, RUNNING, SUSPENDED, UNAVAILABLE }
enum BuildState { PENDING, SUCCEEDED, FAILED }
enum VehicleState { ACTIVE, FROZEN, UNAVAILABLE }
enum CameraState { ORBITING, FREE }

class UiState:
    # sketch state
    var _source: String = ""

    # compile state
    var _build_state = BuildState.SUCCEEDED
    var _build_error: String = ""
    var _build_log: String = ""

    # board state:
    var _board_state = BoardState.UNAVAILABLE
    var _board_error: String = ""
    var _board_log: String = ""

    # attachment state
    var _attachments: Array = []
    var _uart_log: String = ""

    # vehicle state:
    var _vehicle_state = VehicleState.UNAVAILABLE
    var _camera_state = CameraState.FREE


func compile_sketch(sketch, ui_state):
    ui_state._build_pending = true
    
    var token = sketch_builder.queue_build(sketch)

    var future = token.future()

    var tree = get_tree()
    while !future.poll_ready():
        var read = token.read_log()
        if read != "": ui_state._build_log += read
        
        yield(tree, "idle_frame")

    var compile_res = future.get()

    ui_state._build_pending = false
    ui_state._build_success = compile_res.is_ok()

    if compile_res.is_err():
        ui_state._build_error = str(compile_res)
        return false
    
    return true

var _env
func _init(env: EnvInfo):
    _env = env
    sketch_builder = SketchBuilder.new(_env.smce_resources_dir)
    sketch_loader = SketchLoader.new(SketchConfig.new())

func _ready():
    dostuff()

    add_child(universe)
    add_child(camera)
    camera.current = true

    var client = StupidClient.new(null)
    add_child(client)



    var __ = universe.set_world_to("Test/Test")

    camera.set_target_transform(universe.active_world_node.get_camera_starting_pos_hint())


func dostuff():
    var sksource = "/home/ruthgerd/Sources/smce-gd2/tests/sketches/noop/noop.ino"
    var sketch = sketch_loader.skload(sksource)

    var ui_state = UiState.new()

    # make sure the sketch is even valid??

    ui_state._source = sksource
    ui_state._is_compiled = sketch.is_compiled()

    ### queue up sketch build (if not compiled)
    
    if !yield(compile_sketch(sketch, ui_state), "completed"):
        return

    ### setup attachments 

    var board = BoardNode.new()
    add_child(board)

    var uart_puller = UartPuller.new()
    var vehicle_thingy = VehicleThingy.new("vehicle config path or something..", universe)

    board.add_dep(uart_puller)
    board.add_dep(vehicle_thingy)

    board.init()

    var magic = Magic.new(ui_state, board, sketch)
    magic.start()
    magic.stop()
    magic.free()

class Magic:
    extends Object

    var ui_state
    var board
    var sketch

    func _init(_ui_state: UiState, _board, _sketch):
        ui_state = _ui_state
        board = _board
        sketch = _sketch
        ui_state._board_available = true

    func start():
        var res = board.start(sketch)
        if res.is_ok():
            ui_state._board_running = true
            print("started")
        else:
            ui_state._board_error = str(res)
    
    func suspend():
        var res = board.suspend()
        if res.is_ok():
            ui_state._board_running = false
            print("suspended")
        else:
            ui_state._board_error = str(res)
    
    func resume():
        var res = board.resume()

        if res.is_ok():
            ui_state._board_running = true
            print("resumed")
        else:
            ui_state._board_error = str(res)
    
    func stop():
        print("stopped")
        board.free()

        ui_state._board_running = false
        ui_state._board_available = false

class VehicleThingy:
    extends BoardNode.Dependent

    func _init(_str, _uni): pass

class StupidClient:

    signal create_sketch(path)
    signal compile_sketch(desc)
    signal start_board(desc)

    var state = UiState

    func _init(state: UiState):
        pass
