

extends MarginContainer

signal exited
onready var close_btn = $Panel/MarginContainer/VBoxContainer/Control/CloseButton
onready var texteditor = $Panel/MarginContainer/VBoxContainer/Control/TextEdit
onready var save_btn = $Panel/MarginContainer/VBoxContainer/Control/Save
onready var filepicker_window = $Panel/Filepicker
onready var select_window = $Panel/MarginContainer/VBoxContainer/Control
onready var filepicker = $Panel/Filepicker/VBoxContainer/TextAttach/FilePicker

func _gui_input(event: InputEvent):
	if event.is_action_pressed("mouse_left"):
		_on_close()

func _ready() -> void:
	
	close_btn.connect("pressed", self, "_on_close")
	save_btn.connect("pressed", self, "_on_save")
	
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
	select_window.visible=false
