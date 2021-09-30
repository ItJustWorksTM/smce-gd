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

class_name VerticalSketchList
extends PanelContainer

const SCENE_FILE := "res://src/scenes/VerticalSketchList/VerticalSketchList.tscn"
static func instance():	return load(SCENE_FILE).instance()

class ViewModel:
	extends ViewModelBase

	signal select_sketch(sketch_descriptor)
	signal create_new

	var _profile: Observable
	var _active_sketch: Observable
	
	func active_sketch(sketch): return sketch
	func sketches(profile: Profile): return profile.sketches

	func _init(profile: Observable, active_sketch: Observable):
		_profile = profile
		_active_sketch = active_sketch
		set_depend("sketches", [profile])
		set_depend("active_sketch", [active_sketch])
	
	func select_sketch(sketch): emit_signal("select_sketch", sketch)
	func create_new(): emit_signal("create_new")
		
signal context_pressed

onready var sketches_container = $VBox/Scroll/VBox
onready var new_sketch_button = $VBox/Scroll/VBox/NewButton
onready var context_button = $VBox/ContextButton

var model: ViewModel


func init_model(profile, active_sketch): # <Profile>, <SketchDescriptor>
	model = ViewModel.new(Observable.from(profile), Observable.from(active_sketch))

	model.bind_func("sketches", self, "_list_sketches")
	model.bind_func("active_sketch", self, "_set_active")
	
	var __
	__= new_sketch_button.connect("pressed", model, "create_new")
	__= context_button.connect("pressed", self, "_emit_context")


func _ready():
	if false:
		var sketch = SketchDescriptor.new("nice")
		var profile = Observable.new(Profile.new("nigga", [sketch,  SketchDescriptor.new("nice"),  SketchDescriptor.new("nice"),  SketchDescriptor.new("nice")]))
		var active_sketch = Observable.new(sketch)
		model = ViewModel.new(profile, active_sketch)


func _set_active(sketch):
	for btn in _get_sketch_buttons():
		btn.pressed = btn.get_meta("sketch") == sketch


func _get_sketch_buttons() -> Array:
	var existing = sketches_container.get_children()
	existing.erase(new_sketch_button)
	return existing


func _list_sketches(sketches: Array):
	for btn in _get_sketch_buttons(): btn.queue_free()
	
	var i = 1
	for _sketch in sketches:
		var sketch = _sketch
		
		var btn := Button.new()
		btn.toggle_mode = true
		btn.set_meta("sketch", sketch)
		btn.text = str(i)
		btn.keep_pressed_outside = true
		
		assert(btn.connect("toggled", self, "_on_button_toggle", [btn]) == 0)
		
		sketches_container.add_child(btn)
		
		i += 1
	
	sketches_container.remove_child(new_sketch_button)
	sketches_container.add_child(new_sketch_button)
	
	_set_active(model.get_prop("active_sketch"))


func _on_button_toggle(toggled, btn: Button):
	var btn_sketch = btn.get_meta("sketch")
	var active_sketch =  model.get_prop("active_sketch")
	_set_active(active_sketch)
	if !toggled && btn_sketch != active_sketch:
		return
	if toggled && btn_sketch == active_sketch:
		return
	model.select_sketch(btn_sketch if toggled else null)


func _emit_context(): emit_signal("context_pressed")
