#
#  HelpViewer.gd
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

extends Control

signal help_selected
signal exited

onready var close_btn = $LogPopout/Panel/Control/VBoxContainer/MarginContainer/CloseButton

# No functionality at the moment
func init() -> bool:
	print("Loading help viewer...")
	
	return true


func _ready():
	close_btn.connect("pressed", self, "_close")
	
	print("HelpViewer loaded!")
	
	
func _gui_input(event: InputEvent):
	if event.is_action_pressed("mouse_left"):
		_close()


# TODO: Make the animation the same as when closing SketchSelect,
# 		probably has something to do with the tween interpolate values.
func _close() -> void:
	emit_signal("exited")
	var tween = TempTween.new()
	
	add_child(tween)
	tween.interpolate_property(self, "rect_scale:y", 1, 0, 0.3, Tween.TRANS_CUBIC)
	tween.interpolate_property(self, "modulate:a", 1, 0, 0.15)
	tween.start()
	
	yield(tween,"tween_all_completed")
	queue_free()
