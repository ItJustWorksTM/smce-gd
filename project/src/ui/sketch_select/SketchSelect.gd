#
#  SketchSelect.gd
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

signal sketch_selected
signal exited

onready var itemlist = $LogPopout/Panel/Control/VBoxContainer/ItemList
onready var new_btn = $LogPopout/Panel/Control/VBoxContainer/MarginContainer/NewSketch
onready var open_btn = $LogPopout/Panel/Filepicker/VBoxContainer/TextAttach/WindowDialog/Open
onready var save = $LogPopout/Panel/Filepicker/VBoxContainer/TextAttach/WindowDialog/Save
onready var select_btn = $LogPopout/Panel/Control/HBoxContainer/SelectButton
onready var filepicker_window = $LogPopout/Panel/Filepicker
onready var select_window = $LogPopout/Panel/Control
onready var filepicker = $LogPopout/Panel/Filepicker/VBoxContainer/TextAttach/FilePicker
onready var editor = $LogPopout/Panel/Filepicker/VBoxContainer/TextAttach/WindowDialog
onready var editdialog = $LogPopout/Panel/Filepicker/VBoxContainer/TextAttach/EditDialog
onready var savedialog = $LogPopout/Panel/Filepicker/VBoxContainer/TextAttach/SavePicker/SaveDialog
onready var empty = $LogPopout/Panel/Control/EmptyLabel
onready var close_btn = $LogPopout/Panel/Control/VBoxContainer/MarginContainer/CloseButton
onready var error_label = $LogPopout/Panel/Control/HBoxContainer/ErrorLabel
onready var textedit = $LogPopout/Panel/Filepicker/VBoxContainer/TextAttach/WindowDialog/TextEdit

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
	#new_btn.connect("pressed", self, "_show_filepicker")
	new_btn.connect("pressed", self, "_show_editor")
	select_btn.connect("pressed", self, "_select_sketch")
	open_btn.connect("Pressed",self,"_on_Open_pressed")
	editdialog.connect("Pressed",self,"_on_Edit_pressed")
	save.connect("pressed", self, "_on_Save_pressed")
	
	update_list()


func _enter_tree() -> void:
	_open()


func _show_editor() -> void:
	var tween: Tween = TempTween.new()
	add_child(tween)
	editor.popup()
	filepicker_window.visible = false
	tween.interpolate_property(editor, "modulate:a", 0, 1, 0.2, Tween.TRANS_CUBIC)
	tween.interpolate_property(select_window, "modulate:a", 1, 0, 0.2, Tween.TRANS_CUBIC)
	
	tween.start()
	yield(tween, "tween_all_completed")
	select_window.visible = false
	
	
	
func _on_Open_pressed() -> void:
	var tween: Tween = TempTween.new()
	add_child(tween)
	editor.visible = false
	filepicker._wrapped.popup()
	filepicker_window.visible = true
	tween.interpolate_property(filepicker, "modulate:a", 0, 1, 0.2, Tween.TRANS_CUBIC)
	tween.interpolate_property(select_window, "modulate:a", 1, 0, 0.2, Tween.TRANS_CUBIC)
	tween.start()
	yield(tween, "tween_all_completed")
	select_window.visible = false
	filepicker_window.visible = true


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


func _on_Edit_pressed():
	var tween: Tween = TempTween.new()
	add_child(tween)
	editor.visible = false
	editdialog.popup()
	tween.interpolate_property(editdialog, "modulate:a", 0, 1, 0.2, Tween.TRANS_CUBIC)
	tween.interpolate_property(select_window, "modulate:a", 1, 0, 0.2, Tween.TRANS_CUBIC)
	tween.start()
	yield(tween, "tween_all_completed")
	select_window.visible = false
	


func _on_EditDialog_file_selected(path):
	editor.visible = true
	var f = File.new()
	f.open(path,1)
	textedit.text = f.get_as_text()



func _on_Save_pressed():
	var tween: Tween = TempTween.new()
	add_child(tween)
	editor.visible = false
	savedialog.popup()
	tween.interpolate_property(editdialog, "modulate:a", 0, 1, 0.2, Tween.TRANS_CUBIC)
	tween.interpolate_property(select_window, "modulate:a", 1, 0, 0.2, Tween.TRANS_CUBIC)
	# Replace with function body.
	tween.start()
	yield(tween, "tween_all_completed")
	select_window.visible = false

func _on_SaveDialog_file_selected(path):
	var f = File.new() # Replace with function body.
	f.open(path,2)
	f.store_string(textedit.text)
