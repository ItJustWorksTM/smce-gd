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

var model: ViewModel

onready var profile_buttons_container: Control = $VBox/HScroll/Margin/HBox

class ViewModel:
    extends ViewModelExt.WithNode

    signal profile_selected(profile)

    func profiles(profiles: Array): return profiles

    func _init(n, profiles: Observable).(n):
        bind() \
            .profiles.dep([profiles]) \
        
        bind() \
            .profiles.to(self, "_list_profiles") \

    func select_new_profile():
        emit_signal("profile_selected", Profile.new("Profile"))

    func select_profile(index: int):
        emit_signal("profile_selected", self.profiles[index])

    var labels := []
    func _list_profiles(profiles: Array):
        for node in labels:
            node.queue_free()
        labels.clear()
        for profile in profiles:
            var label: ProfileSelectButton = ProfileSelectButton.instance()
            node.profile_buttons_container.add_child(label)
            label.init_model(profile)
            label.rect_min_size.x = 296
            labels.append(label)

func init_model(profiles): # Array<Profile>
    model = ViewModel.new(self, Observable.from(profiles))

func _ready():
    # Debug
    if true:
        var profiles: Observable = Observable.from([Profile.new("Profile1"), Profile.new("Profile2")])
        init_model(profiles)

        while true:
            yield(get_tree().create_timer(3.0), "timeout")
            profiles.value.append(Profile.new("Profile3"))
            profiles.emit_change()

static func instance(): return load(SCENE_FILE).instance()
