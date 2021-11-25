#
#  ProfilePane.gd
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

# TODO:
# * Find a way to keep dirty state and the ability to apply it back to the profile
# * Find a way to allow setting the original profile after the fact with the main goal
#     that the dirty state gets reset back to the currnet original.
# * Find what needs to be passed to get universe access

class_name ProfilePane
extends PanelContainer

const SCENE_FILE := "res://src/scenes/ProfilePane/ProfilePane.tscn"

var model: ViewModel

onready var profile_name_input: LineEdit = $VBox/Margin/NameEdit
onready var switch_btn: Button = $VBox/HBox/SwitchButton
onready var reload_btn: Button = $VBox/HBox/ReloadButton
onready var save_btn: Button = $VBox/HBox/SaveButton
onready var world_list: OptionButton = $VBox/HBox2/WorldOptions
onready var sketches_label: Label = $VBox/Sketches
onready var version_label: Label = $Version
onready var context_btn: Button = $VBox/Margin/ContextButton

class ViewModel:
    extends ViewModelExt.WithNode

    func sketch_count(sketches): return "Sketches: %d" % sketches.size()
    func save_disabled(dirty, orig): return dirty.name == orig.name
    func version(): return "SMCE-gd: %s" % "NOTHING"
    func save_btn_disabled(saveable): return !saveable

    func _init(n).(n): pass

    func _on_init():

        bind() \
            .sketch_count.dep([self.sketches]) \
            .version.dep([]) \
            .save_btn_disabled.dep([self.profile_saveable])

        bind() \
            .worlds.to(self, "_list_worlds") \
            .sketch_count.to(node.sketches_label, "text") \
            .version.to(node.version_label, "text") \
            .save_btn_disabled.to(node.save_btn, "disabled") \
            .profile_name.to(self, "_update_path_edit") \
            .current_world.to(node.world_list, "selected")

        invoke() \
            .context_pressed.on(node.context_btn, "pressed") \
            .save_profile.on(node.save_btn, "pressed") \
            .reload_profile.on(node.reload_btn, "pressed") \
            .switch_profile.on(node.switch_btn, "pressed") \
            ._set_profile_name.on(node.profile_name_input, "text_changed") \
            ._select_world.on(node.world_list, "item_selected")

    func _set_profile_name(name):
        _update_path_edit(self.profile_name.value)
        self.set_profile_name.invoke([name])

    func _select_world(i):
        node.world_list.selected = self.current_world.value
        self.select_world.invoke([i])

    func _update_path_edit(path):
        node.profile_name_input.text = ""
        node.profile_name_input.append_at_cursor(path)

    func _list_worlds(worlds: Array):
        node.world_list.clear()
        for world in worlds:
            node.world_list.add_item(world)

func init_model():
    model = ViewModel.new(self)
    return ViewModel.builder(model)

func _ready():
    # Debug
    if not get_parent() is Control:
        var worlds = Observable.new(["nice", "twice"])
        var name = Observable.new("hello world")

        var set_name = ActionSignal.new()
        var save_profile = ActionSignal.new()
        var noop = ActionSignal.new()

        init_model() \
            .props() \
                .profile_name.to(name) \
                .profile_saveable.to(Observable.new(false)) \
                .worlds.to(worlds) \
                .current_world.to(Observable.new(1)) \
                .sketches.to(Observable.new()) \
            .actions() \
                .set_profile_name.to(set_name) \
                .save_profile.to(save_profile) \
                .switch_profile.to(noop) \
                .select_world.to(noop) \
                .reload_profile.to(noop) \
                .select_world.to(noop) \
                .context_pressed.to(noop) \
            .init()

        while true:
            name.value = yield(set_name, "invoked")

static func instance(): return load(SCENE_FILE).instance()