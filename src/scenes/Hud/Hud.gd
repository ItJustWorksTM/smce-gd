#
#  file.gd
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

class_name Hud
extends Control

class ViewModel:
	extends ViewModelBase
	
	var _profile: Observable
	var _active_sketch: Observable
	
	func sketch_control_visible(active_sketch: SketchDescriptor): return active_sketch == null
	
	
	func _init(profile, active_sketch):
		set_depend("sketch_control_visible", [active_sketch])
	
	func set_active(sketch):
		pass

onready var vertical_sketch_list = $VerticalSketchList
onready var profile_pane = $ProfilePane
onready var sketch_status_control_container = $SketchStatusControl
onready var animation_player := $AnimationPlayer

var profile := Observable.new(Profile.new("Holy Land", [SketchDescriptor.new()]))
var active_sketch := Observable.new(null)

func _ready():
	pass
#	vertical_sketch_list.init_model(profile, active_sketch)
#	vertical_sketch_list.model.connect("select_sketch", self, "select_sketch")
#	vertical_sketch_list.model.connect("create_new", self, "create_new_sketch")
#	vertical_sketch_list.connect("context_pressed", self, "toggle_profile_config")

func select_sketch(sketch):
	if ! sketch in profile.value.sketches:
		return
	
	print("select_sketch: ", sketch)
	
	if sketch == null:
		animation_player.play_backwards("slide_active_sketch")
	elif active_sketch.value == null:
		animation_player.play("slide_active_sketch")
	
	active_sketch.value = sketch

func toggle_sketch_pane(vis):
	if vis:
		animation_player.play("slide_active_sketch")
	else:
		animation_player.play_backwards("slide_active_sketch")
	pass

func create_new_sketch():
	print("create_new_sketch")
	profile.value.sketches.append(SketchDescriptor.new())
	profile.emit_change()

func toggle_profile_config():
	animation_player.play("slide_profile_pane")
	
	pass
