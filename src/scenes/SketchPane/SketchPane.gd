#
#  SketchPane.gd
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

class_name SketchPane
extends PanelContainer

const SCENE_FILE := "res://src/scenes/SketchPane/SketchPane.tscn"
static func instance():	return load(SCENE_FILE).instance()

class ViewModel:
	extends ViewModelBase

	signal reset_vehicle_position
	signal follow_vehicle
	
	signal start_board
	signal stop_board
	signal suspend_board
	signal resume_board

	signal compile_sketch

	func _init():
		pass
	
	func compile_sketch(): emit_signal("compile_sketch")

var model: ViewModel

func init_model():
	model = ViewModel.new()

	var __= sketch_status_control.model.connect("compile_sketch", model, "compile_sketch")


onready var sketch_status_control: SketchStatusControl = $VBoxContainer/SketchStatusControl
