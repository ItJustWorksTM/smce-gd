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

    signal create_sketch(path)
    signal compile_sketch(sk)

    # warning, bad terminology
    signal remove_sketch(sk)

    var _profile: Observable
    var _active_sketch: Observable

    func sketch_control_visible(active_sketch: SketchDescriptor): return active_sketch == null

    func sketches(profile: Profile): return profile.sketches

    func _init(n, profile, dirty_profile).(n):
        _profile = profile
        _active_sketch = Observable.new(null)

        node.vertical_sketch_list.init_model(profile, _active_sketch)
        
        node.profile_pane.init_model(profile, dirty_profile, Observable.new(["no", "no again"]))

        bind() \
            .sketches.dep([profile]) \
            .sketch_control_visible.dep([_active_sketch]) \
            # .sketch_control_visible.to(self, "toggle_sketch_pane")

        bind() \
            .sketches.to(self, "_list_sketches") \
        
        conn(node.vertical_sketch_list.model, "select_sketch", "select_sketch")
        conn(node.vertical_sketch_list.model, "context_pressed", "toggle_profile_config")
        conn(node.vertical_sketch_list.model, "create_new", "create_new_sketch")

    func set_active(sketch):
        pass

    func select_sketch(sketch):
        if sketch != null && ! sketch in _profile.value.sketches:
            return

        print("select_sketch: ", sketch)

        if sketch == null:
            node.animation_player.play_backwards("slide_active_sketch")
        elif _active_sketch.value == null:
            node.animation_player.play("slide_active_sketch")

        _active_sketch.value = sketch

        var ali = node.sketch_status_control_container
        for child in ali.get_children(): child.visible = child.get_meta("sketch") == _active_sketch.value


    func toggle_sketch_pane(vis):
        if vis:
            node.animation_player.play("slide_active_sketch")
        else:
            node.animation_player.play_backwards("slide_active_sketch")

    func create_new_sketch():
        emit_signal("create_sketch")
        _profile.value.sketches.append(SketchDescriptor.new())
        _profile.emit_change()

    func toggle_profile_config():
        node.animation_player.play("slide_profile_pane")

    func _list_sketches(sketches: Array):
        var ali = node.sketch_status_control_container

        if _active_sketch.value != null && not _active_sketch.value in sketches:
            select_sketch(null)

        for child in ali.get_children(): child.queue_free()
        for _i in range(sketches.size()):
            print(_i)

            var inst: SketchPane = SketchPane.instance()

            inst.set_meta("sketch", sketches[_i])

            inst.visible = _active_sketch.value == sketches[_i]

            ali.add_child(inst)

            inst.init_model()

            inst.sketch_status_control.sketch_name_label.text = str(_i)

            fwd_sig(inst.model, "compile_sketch", [sketches[_i]])

            conn(inst.model, "remove_self", "emit_signal", ["remove_sketch", sketches[_i]])



var model: ViewModel

func _ready():
    var profile := Observable.new(Profile.new("Holy Land", []))
    var dirty_profile := Observable.new(profile.value.clone())
    
    var _states = Observable.new([Observable.new(Main.BoardState.READY)])

    model = ViewModel.new(self, profile, dirty_profile)

    while true:
        var del = yield(model, "remove_sketch")

        profile.value.sketches.erase(del)

        profile.emit_change()
