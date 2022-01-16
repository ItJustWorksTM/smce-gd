#
#  collapsable.gd
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

tool
extends VBoxContainer

export var heading_text: String = "Collapsable" setget set_header_text

onready var header: Button = $Button
onready var icon: Label = $Button/Icon
onready var _orig_icon_col: Color = Color(0.08, 0.58, 0.93)

export var disabled = false setget set_disabled

func set_disabled(cond: bool) -> void:
	disabled = cond

	if !header:
		return
	
	header.disabled = cond
	
	icon.add_color_override("font_color", _orig_icon_col)
	if cond:
		icon.add_color_override("font_color", Color(0.39,0.39,0.39))
		header.pressed = false
	

func set_header_text(text: String) -> void:
	heading_text = text
	if header:
		header.text = text
		_update_icon(header.pressed)


func _update_icon(pressed: bool) -> void:
	if ! icon:
		return

	if pressed:
		icon.text = "v"
	else:
		icon.text = ">"


func _ready() -> void:
	_update_icon(false)
	set_disabled(disabled)
	header.text = heading_text
	_on_header_pressed(header.pressed)
	header.connect("toggled", self, "_on_header_pressed")


func _on_header_pressed(pressed: bool) -> void:
	_update_icon(pressed)
	for child in get_children():
		if child != header:
			child.visible = pressed
