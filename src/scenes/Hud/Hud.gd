#
#  Hud.gd
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

class_name Hud
extends Control

onready var vertical_sketch_list = $VerticalSketchList
onready var profile_pane = $ProfilePane
onready var sketch_status_control_container = $SketchStatusControl
onready var animation_player := $AnimationPlayer

class ViewModel:
    extends ViewModelExt.WithNode

    var active_sketch := Observable.new(-1)

    func sketch_control_visible(i): return i >= 0

    func _init(n).(n): pass

    func _on_init():

        bind() \
            .sketch_control_visible.dep([self.active_sketch]) \

        bind() \
            .sketches.to(self, "_list_sketches") \
            .sketch_control_visible.to(self, "toggle_sketch_pane") \
            .active_sketch.to(self, "active_switched")
        
        var noop = ActionSignal.new()

        node.vertical_sketch_list.init_model() \
            .props() \
                .sketches.to(self.sketches) \
                .active_sketch.to(self.active_sketch) \
            .actions() \
                .create_new.to(self.create_new_sketch) \
                .select_sketch.to(self.select_sketch) \
                .context_pressed.to(self.toggle_profile_config.with([true])) \
            .init()

        node.profile_pane.init_model() \
            .props() \
                .profile_name.to(Observable.new("noop")) \
                .profile_saveable.to(Observable.new(false)) \
                .worlds.to(Observable.new([])) \
                .current_world.to(Observable.new(-1)) \
                .sketches.to(Observable.new([])) \
            .actions() \
                .context_pressed.to(self.toggle_profile_config.with([false])) \
                .set_profile_name.to(noop) \
                .save_profile.to(noop) \
                .switch_profile.to(noop) \
                .reload_profile.to(noop) \
                .select_world.to(noop) \
            .init()

    func active_switched(sk):
        var ali = node.sketch_status_control_container
        
        var i = 0
        for child in ali.get_children():
            child.visible = i == self.active_sketch.value
            i += 1

    func select_sketch(sketch):
        if sketch >= -1 && sketch < self.sketches.value.size():
            self.active_sketch.value = sketch
    
    var panel_open := false
    func toggle_sketch_pane(vis):
        if vis && !panel_open:
            node.animation_player.play("slide_active_sketch")
            panel_open = true
        elif !vis:
            node.animation_player.play_backwards("slide_active_sketch")
            panel_open = false

    func create_new_sketch():
        self.create_new_sketch.invoke([])

    func toggle_profile_config(show):
        if show:
            node.animation_player.play("slide_profile_pane")
        else:
            node.animation_player.play_backwards("slide_profile_pane")


    func _list_sketches(_sketches: Array):
        pass
        # var ali = node.sketch_status_control_container

        # if _active_sketch.value != null && not _active_sketch.value in sketches:
        #     select_sketch(null)

        # for child in ali.get_children(): child.queue_free()
        # for _i in range(sketches.size()):
        #     print(_i)

        #     var inst: SketchPane = SketchPane.instance()

        #     inst.set_meta("sketch", sketches[_i])

        #     inst.visible = _active_sketch.value == sketches[_i]

        #     ali.add_child(inst)

        #     inst.init_model()

        #     inst.sketch_status_control.sketch_name_label.text = str(_i)

        #     fwd_sig(inst.model, "compile_sketch", [sketches[_i]])

        #     conn(inst.model, "remove_self", "emit_signal", ["remove_sketch", sketches[_i]])



var model: ViewModel
func init_model():
    model = ViewModel.new(self)
    return ViewModel.builder(model)

func _ready():
    

    var sketches := Observable.new([])
    var create_sketch := ActionSignal.new()

    var _states = Observable.new([Observable.new(Main.BoardState.READY)])

    init_model() \
        .props() \
            .sketches.to(sketches) \
            .create_new_sketch.to(create_sketch) \
        .actions() \
        .init()

    while true:
        yield(create_sketch, "invoked")

        sketches.value += ["bruh!"]
    #     var del = yield(model, "remove_sketch")

    #     profile.value.sketches.erase(del)

    #     profile.emit_change()
