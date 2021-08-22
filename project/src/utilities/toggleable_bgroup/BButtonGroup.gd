#
#  BButtonGroup.gd
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

class_name BButtonGroup
extends ButtonGroup

var _last_pressed: Button = null


func _init():
	for button in get_buttons():
		if ! button.is_connected("toggled", self, "_on_button_toggle"):
			button.connect("toggled", self, "_on_button_toggle", [button])


func _on_button_toggle(toggle: bool, button: Button):
	if button == _last_pressed:
		button.pressed = false
		_last_pressed = null
	else:
		_last_pressed = button
