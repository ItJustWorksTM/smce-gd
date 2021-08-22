#
#  FilePicker.gd
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

signal file_picked
onready var _wrapped: FileDialog = $FileDialog

enum dialog_type { SAVE, OPEN }
export (dialog_type) var mode = dialog_type.OPEN


func _ready():
	# Trigger file refresh
	_wrapped.popup()
	_wrapped.hide()
	_wrapped.connect("file_selected", self, "_on_file_selected")
	_wrapped.get_cancel().connect("pressed", self, "_on_file_selected", [""])
	_wrapped.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)


func _on_file_selected(path: String) -> void:
	emit_signal("file_picked", path)


func _process(_delta: float) -> void:
	
	_wrapped.rect_size = rect_size
	_wrapped.rect_global_position = rect_global_position
	_wrapped.rect_scale = rect_scale
	_wrapped.modulate = modulate
	_wrapped.rect_pivot_offset = rect_pivot_offset
	_wrapped.visible = is_visible_in_tree()
	if mode == dialog_type.SAVE:
		_wrapped.mode = FileDialog.MODE_SAVE_FILE
	elif mode == dialog_type.OPEN:
		_wrapped.mode = FileDialog.MODE_OPEN_FILE


func connect(sig_name: String, object: Object, func_name: String, bind: Array = [], idx: int = 0) -> int:
	return _wrapped.connect(sig_name, object, func_name, bind, idx)
