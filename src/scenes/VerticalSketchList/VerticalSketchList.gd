#
#  file.gd
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

class_name VerticalSketchList
extends PanelContainer

const SCENE_FILE := "res://src/scenes/VerticalSketchList/VerticalSketchList.tscn"

onready var sketches_container = $VBox/Scroll/VBox
onready var new_sketch_button = $VBox/Scroll/VBox/NewButton
onready var context_button = $VBox/ContextButton

class ViewModel:
    extends ViewModelExt.WithNode

    func _init(n).(n): pass

    func _on_init():
        bind() \
            .sketches.to(self, "_list_sketches") \
            .active_sketch.to(self, "_set_active") \

        invoke() \
            .create_new.on(node.new_sketch_button, "pressed") \
            .context_pressed.on(node.context_button, "pressed")

    func _set_active(j):
        var i = 0
        for btn in _get_sketch_buttons():
            btn.pressed = i == j
            i += 1

    func _get_sketch_buttons() -> Array:
        var existing = node.sketches_container.get_children()
        existing.erase(node.new_sketch_button)
        return existing

    func _list_sketches(sketches: Array):
        var existing: Array = _get_sketch_buttons()
        
        for btn in existing: btn.queue_free()

        for i in range(sketches.size()):
            var btn := Button.new()
            node.sketches_container.add_child(btn)
            
            btn.toggle_mode = true
            btn.text = str(i + 1)
            btn.keep_pressed_outside = true
            btn.pressed = self.active_sketch.value == i

            invoke()._on_button_toggle.on(btn, "toggled", [i])


        node.sketches_container.remove_child(node.new_sketch_button)
        node.sketches_container.add_child(node.new_sketch_button)


    func _on_button_toggle(toggled, i):
        var active_sketch = self.active_sketch.value
        if !toggled && i == active_sketch:
            self.select_sketch.invoke([-1])
            return
        
        if !toggled && i != active_sketch:
            return
        
        _set_active(self.active_sketch.value)
        self.select_sketch.invoke([i])


var model: ViewModel

func init_model():
    model = ViewModel.new(self)
    return ViewModel.builder(model)

func _ready():
    if false:
        var sketches = Observable.new([SketchDescriptor.new("nice"),  SketchDescriptor.new("nice"),  SketchDescriptor.new("nice")])
        
        var active_sketch = Observable.new(1)
        var new = ActionSignal.new()
        var select = ActionSignal.new()

        init_model() \
            .props() \
                .sketches.to(sketches) \
                .active_sketch.to(active_sketch) \
            .actions() \
                .create_new.to(new) \
                .select_sketch.to(select) \
                .context_pressed.to(ActionSignal.new()) \
            .init()

        while true:
            yield(new, "invoked")
            sketches.value += [SketchDescriptor.new("nice2")]

            var i = yield(select, "invoked")

            active_sketch.value = i

        return

static func instance(): return load(SCENE_FILE).instance()
