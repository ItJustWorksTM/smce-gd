#
#  SketchStatusControl.gd
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

class_name SketchStatusControl
extends PanelContainer

const SCENE_FILE := "res://src/scenes/SketchStatusControl/SketchStatusControl.tscn"
static func instance():	return load(SCENE_FILE).instance()

class ViewModel:
	extends ViewModelBase

	signal compile_sketch
	signal open_log

	func sketch_name(): return "Nothing.ino"
	func sketch_status(): "Compiled"

	func _init():
		pass
	
	func compile_sketch(): emit_signal("compile_sketch")
	func open_log(): emit_signal("open_log")

var model: ViewModel

func init_model():
	model = ViewModel.new()

	model.bind_prop("sketch_status", sketch_status_label, "text")
	model.bind_prop("sketch_name", sketch_name_label, "text")

	var __= compile_button.connect("pressed", model, "compile_sketch")
	__= log_button.connect("pressed", model, "open_log")

onready var sketch_name_label: Label = $VBox/SketchName
onready var sketch_status_label: Label = $VBox/SketchStatus

onready var compile_button: Button = $HBox/CompileButton
onready var log_button: Button = $HBox/LogButton
