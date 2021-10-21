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

func _init(_env: EnvInfo):
    pass

func _ready():

    prepare_board()

    return

    add_child(universe)
    add_child(camera)
    camera.current = true
    

    var res = universe.set_world_to("Test/Test")
    
    assert(res)

    camera.set_target_transform(universe.active_world_node.get_camera_starting_pos_hint())

class Attachment:
    

    func required_hardware() -> Array:
        var pin := GpioDriverConfig.new()
        pin.pin = 123
        pin.read = false
        
        var spec = BoardDeviceSpec.new() \
                        .with_name("Attachment") \
                        .with_atomic_u32("id") \
                        .with_atomic_u32("value")
        
        return [pin, BoardDeviceConfig.new().with_spec(spec)]

func prepare_board():

    var needed := []
    for props in [{}, {}]:
        var attachment = Attachment.new()
        # inflate attachment with config?

        for hw in attachment.required_hardware():
            var dupe = false
            for a in needed:
                if Reflect.value_compare(a, hw):
                    dupe = true
                    push_error("dupe detected %d" % needed.size())
                    break
            if !dupe:
                needed.push_back(hw)
    print(needed)
    
    pass
