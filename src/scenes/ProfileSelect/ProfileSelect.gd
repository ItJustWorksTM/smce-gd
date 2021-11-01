#
#  ProfileSelect.gd
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

class_name ProfileSelect
extends Control

const SCENE_FILE := "res://src/scenes/ProfileSelect/ProfileSelect.tscn"
static func instance():    return load(SCENE_FILE).instance()

class ViewModel:
    extends ViewModelBase

    signal profile_selected(profile)

    func profiles(profiles: Array): return profiles

    func _init(profiles: Observable):
        set_depend("profiles", [profiles])

    func select_new_profile(): emit_signal("profile_selected", Profile.new("Profile"))

    func select_profile(index: int): emit_signal("profile_selected", get_prop("profiles")[index])


onready var profile_buttons_container: Control = $VBox/HScroll/Margin/HBox

var model: ViewModel


func init_model(profiles): # Array<Profile>
    model = ViewModel.new(Observable.from(profiles))
    model.bind_func("profiles", self, "_list_profiles")


func _ready():
    # Debug
    if true:
        var profiles: Observable = Observable.from([Profile.new("Profile1"), Profile.new("Profile2")])
        init_model(profiles)

        while true:
            yield(get_tree().create_timer(3.0), "timeout")
            profiles.value.append(Profile.new("Profile3"))
            profiles.emit_change()


var labels := []
func _list_profiles(profiles: Array):
    for node in labels:
        node.queue_free()
    labels.clear()
    for profile in profiles:
        var label: ProfileSelectButton = ProfileSelectButton.instance()
        profile_buttons_container.add_child(label)
        label.init_model(profile)
        label.rect_min_size.x = 296
        labels.append(label)

