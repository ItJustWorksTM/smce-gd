

extends MarginContainer

signal exited
onready var close_btn = $Panel/MarginContainer/VBoxContainer/Control/CloseButton
onready var texteditor = $Panel/MarginContainer/VBoxContainer/Control/TextEdit
onready var save_btn = $Panel/MarginContainer/VBoxContainer/Control/Save
onready var file_btn = $Panel/MarginContainer/VBoxContainer/Control/File
onready var filepicker_window = $Panel/Filepicker
onready var openpicker_window = $Panel/Openpicker
onready var window = $Panel
onready var main = $PrewiewPopout
onready var window1 = $Panel/MarginContainer
onready var window2 = $Panel/MarginContainer/VBoxContainer
onready var select_window = $Panel/MarginContainer/VBoxContainer/Control
onready var select_window1 = $Panel/MarginContainer/VBoxContainer
onready var filepicker = $Panel/Filepicker/VBoxContainer/TextAttach/FilePicker
onready var openpicker = $Panel/Openpicker/VBoxContainer/TextAttach/OpenPicker

func _gui_input(event: InputEvent):
	if event.is_action_pressed("mouse_left"):
		_on_close()

func _ready() -> void:
	close_btn.connect("pressed", self, "_on_close")
	#save_btn.connect("pressed", self, "_on_save")
	file_btn.get_popup().add_item("Save")
	file_btn.get_popup().add_item("Open")
	file_btn.get_popup().add_item("Close")
	file_btn.get_popup().connect("id_pressed",self,"_on_item_pressed")
	
func _on_save() -> void:
	var tween: Tween = TempTween.new()
	add_child(tween)
	filepicker._wrapped.popup()
	filepicker_window.visible = true
	tween.interpolate_property(filepicker, "modulate:a", 0, 1, 0.2, Tween.TRANS_CUBIC)
	tween.interpolate_property(select_window, "modulate:a", 1, 0, 0.2, Tween.TRANS_CUBIC)
	tween.start()
	yield(tween, "tween_all_completed")
	select_window.visible = false
	
func _on_open() -> void:
	var tween: Tween = TempTween.new()
	add_child(tween)
	openpicker._wrapped.popup()
	openpicker_window.visible = true
	tween.interpolate_property(openpicker, "modulate:a", 0, 1, 0.2, Tween.TRANS_CUBIC)
	tween.interpolate_property(select_window, "modulate:a", 1, 0, 0.2, Tween.TRANS_CUBIC)
	tween.start()
	yield(tween, "tween_all_completed")
	select_window.visible = false
	
func _on_item_pressed(id):
	var item_name = file_btn.get_popup().get_item_text(id)
	if item_name == 'Save':
		_on_save()
	if item_name == 'Open':
		_on_open()
	if item_name=='Close':
		_on_close()
		
#	print(item_name+ 'pressed')

	
func _on_close() -> void:
	emit_signal("exited")
	
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "rect_scale:y", 1, 0, 0.3, Tween.TRANS_CUBIC)
	tween.interpolate_property(self, "modulate:a", 1, 0, 0.15)
	
	tween.start()
	yield(tween,"tween_all_completed")
	queue_free()

#onready var _text_edit = $Panel/MarginContainer/VBoxContainer/Control/TextEdit
#onready var text_field = null setget set_text_field
#func set_text_field(node: Control) -> void:
	#if is_instance_valid(text_field):
	#	remove_child(text_field)
	#if node:
	#	_text_edit.add_child(node)
	#	text_field = node
func _on_FilePicker_file_picked(path):
	var f = File.new() # Replace with function body.
	f.open(path,2)
	f.store_string(texteditor.text)
	filepicker.visible=false
	window.visible=false


func _on_TextEdit_ready():
	pass # Replace with function body.
var preview_log_text_field = null	
func _on_OpenPicker_file_picked(path):
	var f1 =File.new()
	f1.open(path,1)
	texteditor.text =f1.get_as_text()
	texteditor.visible = true
	openpicker.visible=false
	window.visible=true
