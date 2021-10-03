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

onready var vertical_sketch_list = $VerticalSketchList
onready var profile_pane = $ProfilePane
onready var sketch_status_control_container = $SketchStatusControl
onready var animation_player := $AnimationPlayer

class ViewModel:
	extends ViewModelExt.WithNode
	
	var _profile: Observable
	var _active_sketch: Observable
	
	func sketch_control_visible(active_sketch: SketchDescriptor): return active_sketch == null
	
	
	func _init(n, profile, active_sketch).(n):
		_profile = profile
		_active_sketch = active_sketch
		bind() \
			.sketch_control_visible.dep([active_sketch])
		
		node.vertical_sketch_list.init_model(profile, active_sketch)
		
		conn(node.vertical_sketch_list.model, "select_sketch", "select_sketch")
		conn(node.vertical_sketch_list.model, "create_new", "create_new_sketch")
		conn(node.vertical_sketch_list.model, "context_pressed", "toggle_profile_config")
	
	
	func set_active(sketch):
		pass
	
	func select_sketch(sketch):
		if sketch != null && ! sketch in _profile.value.sketches:
			return
		
		print("select_sketch: ", sketch)
		
		if sketch == null:
			node.animation_player.play_backwards("slide_active_sketch")
		elif _active_sketch.value == null:
			node.animation_player.play("slide_active_sketch")
		
		_active_sketch.value = sketch

	func toggle_sketch_pane(vis):
		if vis:
			node.animation_player.play("slide_active_sketch")
		else:
			node.animation_player.play_backwards("slide_active_sketch")
		pass

	func create_new_sketch():
		print("create_new_sketch")
		_profile.value.sketches.append(SketchDescriptor.new())
		_profile.emit_change()

	func toggle_profile_config():
		node.animation_player.play("slide_profile_pane")
		
		pass

var model: ViewModel

func _ready():
	var profile := Observable.new(Profile.new("Holy Land", [SketchDescriptor.new()]))
	var active_sketch := Observable.new(null)
	
	model = ViewModel.new(self, profile, active_sketch)


