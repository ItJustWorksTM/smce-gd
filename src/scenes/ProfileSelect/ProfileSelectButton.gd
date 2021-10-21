#
#  ProfileSelectButton.gd
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

class_name ProfileSelectButton
extends Control

const SCENE_FILE := "res://src/scenes/ProfileSelect/ProfileSelectButton.tscn"
static func instance():    return load(SCENE_FILE).instance()

class ViewModel:
    extends ViewModelBase
    
    signal pressed
    
    func profile_name(profile: Profile): return profile.name
    func profile_info(profile: Profile):
        return "[color=%s]World: %s[/color]\nSketches: %d" % ["white" if true else "red", profile.environment, profile.sketches.size()]
    
    func _init(profile: Observable):
        set_depend("profile_info", [profile])
        set_depend("profile_name", [profile])
        
    
    func pressed(): emit_signal("pressed")

onready var profile_name_label: Label = $MarginContainer/VBoxContainer/ProfileNameLabel
onready var profile_info_label: RichTextLabel = $MarginContainer/VBoxContainer/ProfileInfoLabel

var model: ViewModel


func init_model(profile): # <Profile>
    model = ViewModel.new(Observable.from(profile))
    model.bind_prop("profile_name", profile_name_label, "text")
    model.bind_prop("profile_info", profile_info_label, "bbcode_text")

