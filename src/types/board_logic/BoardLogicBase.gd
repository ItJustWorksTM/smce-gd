#
#  BoardLogicBase.gd
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

class_name BoardLogicBase
extends Node

var _sketch: Sketch
var _sketch_builder: SketchBuilder

var _board: Board

var _compile_token: SketchBuilder.Token

func _init(sketch_builder, sketch: Sketch):
    _sketch = sketch
    _sketch_builder = sketch_builder   

func setup():
    if !_sketch.is_compiled():
        assert(false, "sketch needs to be compiled such that we can derive needed devices")
        return false
    
    var board_builder = BoardBuilder.new()

    var hook_state = _setup_hook(board_builder)

    # Make sure that we at least match the sketches' devices
    for device in _sketch.config.genbind_devices:
        board_builder.request([BoardDeviceConfig.new().with_spec(device)])

    var res = board_builder.consume()

    if res.is_err():
        assert(false, res)
        return false
    
    _board = res.get_value()

    hook_state.resume()

    return true

func compile():
    if _compile_token != null:
        return
    
    _compile_token = _sketch_builder.queue_build(_sketch)

    _compile_started_hook(_compile_token)

func start():
    return _board.start(_sketch) if !_board.is_active() else _board.resume() 

func pause():
    return _board.suspend()

func stop():
    var res = _board.terminate()
    if res.is_ok():
        _terminate_hook(res.get_value())
    return res

func _setup_hook(_builder):
    yield()

func _terminate_hook(_code):
    pass

func _compile_started_hook(_token):
    pass

func _compile_finished_hook(_res):
    pass

func _process(__):
    if _board != null:
        var res = _board.poll()
        if res.is_ok():
            return
        
        _terminate_hook(res.get_value())
    
    if _compile_token != null && _compile_token.future().poll_ready():
        
        _compile_finished_hook(_compile_token.future().get())

        _compile_token = null

