#
#  SketchSelect.gd
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

signal sketch_selected
signal exited

onready var itemlist = $LogPopout/Panel/Control/VBoxContainer/ItemList
onready var new_btn = $LogPopout/Panel/Control/VBoxContainer/MarginContainer/NewSketch
onready var select_btn = $LogPopout/Panel/Control/HBoxContainer/SelectButton
onready var filepicker_window = $LogPopout/Panel/Filepicker
onready var select_window = $LogPopout/Panel/Control
onready var filepicker = $LogPopout/Panel/Filepicker/VBoxContainer/TextAttach/FilePicker
onready var empty = $LogPopout/Panel/Control/EmptyLabel
onready var close_btn = $LogPopout/Panel/Control/VBoxContainer/MarginContainer/CloseButton
onready var error_label = $LogPopout/Panel/Control/HBoxContainer/ErrorLabel

var _sketch_manager: SketchManager = null
var _selected_sketch = null


func init(sketch_manager: SketchManager) -> bool:
	if ! is_instance_valid(sketch_manager):
		return false
	_sketch_manager = sketch_manager
	_sketch_manager.connect("sketch_added", self, "update_list")
	update_list()
	
	return true


func _gui_input(event: InputEvent):
	if event.is_action_pressed("mouse_left"):
		_close()


func _ready():
	if ! is_instance_valid(_sketch_manager):
		init(SketchManager.new())
	
	filepicker._wrapped.get_cancel().connect("pressed", self, "_hide_filepicker")
	filepicker._wrapped.connect("file_selected", self, "_on_file_selected")
	
	itemlist.connect("item_selected", self, "_on_item_selected")
	itemlist.connect("nothing_selected", self, "_on_item_selected", [-1])
	itemlist.connect("item_activated", self, "_on_sketch_selected")
	
	close_btn.connect("pressed", self, "_close")
	new_btn.connect("pressed", self, "_show_filepicker")
	select_btn.connect("pressed", self, "_select_sketch")
	
	update_list()


func _enter_tree() -> void:
	_open()


func _show_filepicker() -> void:
	var tween: Tween = TempTween.new()
	add_child(tween)
	filepicker._wrapped.popup()
	filepicker_window.visible = true
	tween.interpolate_property(filepicker, "modulate:a", 0, 1, 0.2, Tween.TRANS_CUBIC)
	tween.interpolate_property(select_window, "modulate:a", 1, 0, 0.2, Tween.TRANS_CUBIC)
	
	tween.start()
	yield(tween, "tween_all_completed")
	select_window.visible = false


func _hide_filepicker() -> void:
	var tween: Tween = TempTween.new()
	add_child(tween)
	select_window.visible = true
	tween.interpolate_property(filepicker, "modulate:a", 1, 0, 0.2, Tween.TRANS_CUBIC)
	tween.interpolate_property(select_window, "modulate:a", 0, 1, 0.2, Tween.TRANS_CUBIC)
	
	tween.start()
	yield(tween, "tween_all_completed")
	
	filepicker_window.visible = false


func update_list():
	if ! is_instance_valid(itemlist):
		return
	
	itemlist.clear()
	
	var i = 0
	for sketch_path in _sketch_manager.sketches:
		itemlist.add_item("  " + sketch_path)
		itemlist.set_item_metadata(i, _sketch_manager.sketches[sketch_path])
		i += 1
	
	empty.visible = itemlist.items.empty()


func _close() -> void:
	emit_signal("exited", _selected_sketch)
	var tween = TempTween.new()
	
	add_child(tween)
	tween.interpolate_property(self, "rect_scale:y", 1, 0, 0.3, Tween.TRANS_CUBIC)
	tween.interpolate_property(self, "modulate:a", 1, 0, 0.15)
	tween.start()
	
	yield(tween,"tween_all_completed")
	queue_free()


func _open() -> void:
	var tween = TempTween.new()
	add_child(tween)
	tween.interpolate_property(self, "rect_scale:y", 0, 1, 0.15, Tween.TRANS_CUBIC)
	tween.interpolate_property(self, "modulate:a", 0, 1, 0.15)
	tween.start()


func _select_sketch() -> void:
	var selected = itemlist.get_selected_items()
	
	if selected.empty():
		return
	
	var sketch: Sketch = itemlist.get_item_metadata(selected[0])
	
	_selected_sketch = sketch
	emit_signal("sketch_selected", sketch)
	print("Sketch selected: %s - %s" % [sketch.get_uuid(), sketch.get_source()])
	_close()


func _on_item_selected(index):
	select_btn.disabled = index < 0


func _on_file_selected(file: String):
	error_label.text = " "
	
	var res = _sketch_manager.make_sketch(file)
	
	if ! res.ok():
		printerr(res.error())
		error_label.text = "Error for \"%s\": %s" % [file.get_file(), res.error()]
	
	_hide_filepicker()


func _on_sketch_selected(_index: int) -> void:
	_select_sketch()

