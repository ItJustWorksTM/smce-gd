#
#  ProfileSelector.gd
#  Copyright 2022 ItJustWorksTM
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

extends Control

var profile_button_t = load("res://src/ui/profile_selector/ProfileButton.tscn")

signal profile_selected

onready var attach = $VBoxContainer/CenterContainer/MarginContainer/HBoxContainer
onready var fresh_btn = attach.get_node("Button")

func _ready() -> void:
	fresh_btn.connect("pressed", self, "_on_profile_pressed", [ProfileConfig.new()])


func display_profiles(arr: Array) -> void:
	for child in attach.get_children():
		if child != fresh_btn:
			child.queue_free()
	for profile in arr:
		var btn = profile_button_t.instance()
		attach.add_child(btn)
		btn.display_profile(profile)
		btn.connect("pressed", self, "_on_profile_pressed", [profile])
		


func _on_profile_pressed(profile) -> void:
	emit_signal("profile_selected", profile)


