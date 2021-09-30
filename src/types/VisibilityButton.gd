#
#  file.gd
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

tool
class_name VisibilityButton
extends Button

export(NodePath) var node_path: NodePath

func get_node_to_set() -> Control: return get_node_or_null(node_path) as Control

func _toggled(button_pressed):
	var node := get_node_to_set()
	if is_instance_valid(node):
		node.visible = button_pressed

func _ready():
	connect("button_down", self, "_button_down")
	connect("button_up", self, "_button_up")

func _button_down():
	if !toggle_mode:
		_toggled(true)

func _button_up():
	if !toggle_mode:
		_toggled(false)
