#
#  ShootyVisualizer.gd
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

extends Button
class_name ShootyVisualizer

var _shooty = null

func display_shooty(shooty) -> bool:
	if ! shooty:
		return false
	_shooty = shooty
	connect("pressed", shooty, "shoot")
	set_process(true)
	return true

func _process(_delta: float) -> void:
	if ! _shooty:
		set_process(false)
		return

	var cooldown = _shooty.cooldown()
	disabled = cooldown > 0
	text = "Ready" if cooldown == 0 else "Cooldown: %.2f" % [cooldown]


