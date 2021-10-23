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

var universe := Universe.new()
var camera := ControllableCamera.new()
var sketch_builder: SketchBuilder
var sketch_loader: SketchLoader

func _init(_env: EnvInfo):
    sketch_builder = SketchBuilder.new(_env.smce_resources_dir)
    sketch_loader = SketchLoader.new(SketchConfig.new())

    var sketch = sketch_loader.skload("/home/ruthgerd/Sources/smce-gd2/tests/sketches/noop/noop.ino")

    var token = sketch_builder.queue_build(sketch)

    var future = token.future()

    print(yield(future.yield(), "completed"))

    if future.get().is_err():
        print(future.read_log())
        return

    var builder = BoardBuilder.new()

    builder.request([])
    
    var maybe_board = builder.create(sketch)

    assert(maybe_board.is_ok(), maybe_board)

    var board = maybe_board.get_value()

    board.start()

    print("started")

func _ready():

    add_child(universe)
    add_child(camera)
    camera.current = true
    

    var res = universe.set_world_to("Test/Test")
    
    assert(res)

    camera.set_target_transform(universe.active_world_node.get_camera_starting_pos_hint())


# class Attachment:
#     class Controller:
#         var pin: GpioPin
#         var device
    
#     static func make_controller(builder: BoardBuilder, props: Dictionary):
#         var pin := GpioDriverConfig.new()
#         pin.pin = props["pin"]
        
#         var spec = BoardDeviceSpec.new() \
#                         .with_name("Attachment") \
#                         .with_atomic_u32("id") \
#                         .with_atomic_u32("value")
        
#         var requested = [pin, BoardDeviceConfig.new().with_spec(spec)]

#         var hardware = yield(builder.request(requested), "completed")

#         if hardware == null:
#             return null

#         var controller = Controller.new()
#         controller.pin = hardware[0]
#         controller.device = hardware[1]
#         controller.device.id = props["id"]

#         return controller

#     var _ctl: Controller

#     func set_controller(ctl): _ctl = ctl

#     func _init(ctl: Controller):
#         _ctl = ctl

# func prepare_board():

#     var idk = BoardBuilder.new()

#     for props in [{ "pin": 123, "id": 99 }, { "pin": 124, "id": 1 }]:
#         var _attachment = Attachment.make_controller(idk, props)
#         # do some yield magic and construct the attachment
    
#     var board = idk.consume()
#     assert(board.is_ok(), board)


#     board = board.get_value()
    
#     # yield(Yield.yield(), "completed")
    
#     pass
