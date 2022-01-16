#
#  DebugCanvas.gd
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


class Draw:
	var begin: Vector3
	var end: Vector3
	var color: Color
	var tickness: float

	func _init(_begin, _end, _color, _tickness):
		begin = _begin
		end = _end
		color = _color
		tickness = _tickness


export var disabled: bool = false setget set_disabled

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug_canvas"):
		set_disabled(!disabled)

func set_disabled(v: bool) -> void:
	disabled = v
	set_process(v)


var _to_draw: Array = []
var _clear: bool = true


func add_draw(begin: Vector3, end: Vector3, color: Color = Color(0, 1, 0, 0.5), tickness: float = 7) -> void:
	if disabled:
		return
	_to_draw.push_back(Draw.new(begin, end, color, tickness))
	pass


func _physics_process(delta: float) -> void:
	# Dont update the screen if we have nothing to draw
	# But update one more time to clear the last frame
	if _to_draw.empty():
		if _clear:
			update()
			_clear = false
		return
	_clear = true
	update()


func _draw() -> void:
	var camera = get_viewport().get_camera()
	for draw in _to_draw:
		draw_line(
			camera.unproject_position(draw.begin),
			camera.unproject_position(draw.end),
			draw.color,
			draw.tickness,
			true
		)
	_to_draw = []
