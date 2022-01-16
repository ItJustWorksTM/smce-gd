#
#  SketchLog.gd
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

extends PanelContainer

onready var copy_clipboard_btn = $VBoxContainer/HBoxContainer/Copy
onready var popout_btn = $VBoxContainer/HBoxContainer/Open
onready var log_box = $VBoxContainer/LogBox

func _ready() -> void:
	copy_clipboard_btn.connect("pressed", self, "_on_copy_pressed")
	popout_btn.connect("pressed", self, "_on_popout_pressed")


func _on_copy_pressed() -> void:
	OS.clipboard = log_box.text


func _on_popout_pressed() -> void:
	var window = preload("res://src/ui/sketch_control/LogPopout.tscn").instance()
	get_tree().root.add_child(window)
	$VBoxContainer.remove_child(log_box)
	window.text_field = log_box
	window.connect("exited", $VBoxContainer, "call", ["add_child", log_box])
	
	popout_btn.disabled = true
	window.connect("exited", popout_btn, "set", ["disabled", false])
	
