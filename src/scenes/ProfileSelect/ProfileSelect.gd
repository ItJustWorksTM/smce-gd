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

    func _init(n).(n): pass

    func _on_init():
        bind() \
            .profiles.to(self, "_list_profiles") \
        
    func _list_profiles(profiles: Array):
        var alias = node.profile_buttons_container

        var existing = alias.get_children()
        for node in existing: node.queue_free()
        
        for i in range(profiles.size()):
            var label: ProfileSelectButton = ProfileSelectButton.instance()
            alias.add_child(label)
            
            label.init_model() \
                .props() \
                    .profile.to(profiles[i]) \
                .actions() \
                    .pressed.to(self.selected.with([i])) \
                .init()
            
            label.rect_min_size.x = 296



func init_model():
    model = ViewModel.new(self)
    return ViewModel.builder(model)

func _ready():
    self.rect_pivot_offset = self.rect_size / 2
    
    # Debug
    if true:
        var profiles: Observable = Observable.new([Profile.new("Profile1"), Profile.new("Profile2")])

        var on_selected = ActionSignal.new()

        init_model() \
            .props() \
                .profiles.to(profiles) \
            .actions() \
                .selected.to(on_selected) \
            .init()

static func instance(): return load(SCENE_FILE).instance()
