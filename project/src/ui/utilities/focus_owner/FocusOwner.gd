#
#  FocusOwner.gd
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


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left"):
		FocusOwner.release_focus()

func has_focus() -> bool:
	return get_focus_owner() != null

func release_focus() -> void:
	if has_focus():
		get_focus_owner().release_focus()
