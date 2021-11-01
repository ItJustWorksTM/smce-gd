#
#  SketchEditor.gd
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


extends Node2D

var sketch_path = ""


func _ready():
	if(sketch_path):
		_on_select_file(sketch_path)

func _on_open_file():
	$OpenDialogPopUp.popup()

func _on_select_file(path):
	var sketch = File.new()
	sketch.open(path, 1)
	$Edit.text = sketch.get_as_text()

func _on_save_file(path):
	var sketch = File.new()
	sketch.open(path, 2)
	sketch.store_string($Edit.text)

func _on_save():
	$SaveDialogPopUp.popup()

func _on_close():
	self.queue_free()