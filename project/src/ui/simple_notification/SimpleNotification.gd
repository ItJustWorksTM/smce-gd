#
#  SimpleNotification.gd
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

class_name SimpleNotification
extends Button

signal stop_notify

onready var header: RichTextLabel = $MarginContainer/Label
onready var button: Button = $Button
onready var progress: ColorRect = $ColorRect

var has_progress = false
var is_button = false
var custom_text = ""

onready var _animation: AnimationPlayer = $AnimationPlayer

func _ready():
	progress.visible = has_progress
	button.visible = is_button
	header.bbcode_text = custom_text

	button.connect("pressed", self, "_on_stop_pressed")
	_animation.play("progress")
	_animation.seek(rand_range(0,10), true)

func _on_stop_pressed():
	button.disabled = true
	emit_signal("stop_notify")


func _process(delta):
	rect_min_size.y = $MarginContainer.rect_size.y


func setup(owner: Node, text: String, timeout: float = -1, progress: bool = false, button: bool = false):
	var notification = self
	
	has_progress = progress
	is_button = button
	custom_text = text
	
	if timeout > 0:
		notification.connect("pressed", notification, "emit_signal", ["stop_notify"])
	
	owner.connect("tree_exiting", notification, "emit_signal", ["stop_notify"])
	
	return self
