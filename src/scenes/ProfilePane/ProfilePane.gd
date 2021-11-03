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

class ViewModel:
    extends ViewModelExt.WithNode

    signal save_profile()
    signal reload_profile()
    signal switch_profile()

    var _profile: Observable # <Profile>
    var _dirty_profile: Observable # <Profile>

    # TODO: Potentially not needed? the input field is synced with this,
    # though when the profile changes we need to be able to set the input field
    func profile_name(profile: Profile): return profile.name

    func sketch_count(profile: Profile): return "Sketches: %d" % profile.sketches.size()

    func save_disabled(dirty, orig): return dirty.name == orig.name

    # Not sure if needed as we can get an array already from the Universe
    func worlds(arr): return arr

    func version(): return "SMCE-gd: %s" % "NOTHING"

    func delete(n): print(n)

    func _init(n, profile: Observable, dirty_profile, worlds: Observable).(n):
        _profile = profile
        _dirty_profile = dirty_profile
        profile.bind_change(self, "_set_dirty")

        bind() \
            .worlds.dep([worlds]) \
            .sketch_count.dep([_dirty_profile]) \
            .version.dep([]) \
            .save_disabled.dep([_dirty_profile, profile]) \
            .profile_name.dep([_dirty_profile])

        bind() \
            .worlds.to(self, "_list_worlds") \
            .sketch_count.to(node.sketches_label, "text") \
            .version.to(node.version_label, "text") \
            .save_disabled.to(node.save_btn, "disabled") \
            .profile_name.to(node.profile_name_input, "text")

        var a = Observable2.new(self, "save_disabled")
        a.connect("value_changed", self, "delete")
        a.reference()

        conn(node.save_btn, "pressed", "save_profile")
        conn(node.reload_btn, "pressed", "reload_profile")
        conn(node.switch_btn, "pressed", "switch_profile")
        conn(node.profile_name_input, "text_changed", "set_profile_name")
        # TODO: two way binding so that the selected world is displayed
        conn(node.world_list, "item_selected", "_on_world_selected")


    func set_profile_name(name: String):
        _dirty_profile.value.name = name

    func save_profile(): emit_signal("save_profile")

    func reload_profile():
        _set_dirty(_profile.value)
        emit_signal("reload_profile")

    func switch_profile(): emit_signal("switch_profile")

    func set_world(world: String):
        print("set world to: ", world)

    func _set_dirty(profile: Profile):
        _dirty_profile.value = profile.clone()

    func _list_worlds(worlds: Array):
        node.world_list.clear()
        for world in worlds:
            node.world_list.add_item(world)
            node.world_list.set_item_metadata(node.world_list.get_item_count() - 1, world)

    func _on_world_selected(index: int):
        set_world(node.world_list.get_item_metadata(index))


func init_model(profile, dirty_profile, worlds): # <Profile>, <Array<String>>

    model = ViewModel.new(self, Observable.from(profile), Observable.from(dirty_profile), Observable.from(worlds))

func _ready():
    # Debug
    if not get_parent() is Control:
        var profile = Observable.new(Profile.new("A", [1,2,3,4], "C"))
        var dirty = Observable.new(profile.value.clone())
        init_model(
            profile,
            dirty,
            Observable.new(["nice", "twice"])
        )

        while true:
            yield(model, "save_profile")

            profile.value = dirty.value.clone()
            

static func instance(): return load(SCENE_FILE).instance()