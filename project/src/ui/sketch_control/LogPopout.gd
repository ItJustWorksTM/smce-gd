#
#  LogPopout.gd
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

extends MarginContainer

signal exited

onready var close_btn = $Panel/MarginContainer/VBoxContainer/Control/CloseButton
onready var copy_btn = $Panel/MarginContainer/VBoxContainer/Control/CopyButton

onready var _text_attach = $Panel/MarginContainer/VBoxContainer/TextAttach
onready var text_field = null setget set_text_field

func _gui_input(event: InputEvent):
	if event.is_action_pressed("mouse_left"):
		_on_close()


func _ready() -> void:
	copy_btn.disabled = true
	close_btn.connect("pressed", self, "_on_close")
	copy_btn.connect("pressed", self, "_on_copy")


func _on_copy() -> void:
	OS.clipboard = text_field.text


func _on_close() -> void:
	if text_field:
		_text_attach.remove_child(text_field)
	
	emit_signal("exited")
	
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "rect_scale:y", 1, 0, 0.3, Tween.TRANS_CUBIC)
	tween.interpolate_property(self, "modulate:a", 1, 0, 0.15)
	
	tween.start()
	yield(tween,"tween_all_completed")
	queue_free()


func set_text_field(node: Control) -> void:
	copy_btn.disabled = true
	if is_instance_valid(text_field):
		remove_child(text_field)
	if node:
		_text_attach.add_child(node)
		text_field = node
		copy_btn.disabled = false


func _enter_tree() -> void:
	FocusOwner.release_focus()
	var tween: Tween = TempTween.new()
	add_child(tween)
	tween.interpolate_property(self, "rect_scale:y", 0.5, 1, 0.15, Tween.TRANS_CUBIC)
	tween.interpolate_property(self, "modulate:a", 0, 1, 0.15)
	tween.start()
	
