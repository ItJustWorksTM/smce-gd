extends MarginContainer

signal exited

onready var close_btn = $Panel/MarginContainer/VBoxContainer/Control/CloseButton
onready var clopy_btn = $Panel/MarginContainer/VBoxContainer/Control/CopyButton

onready var _text_attach = $Panel/MarginContainer/VBoxContainer/TextAttach
onready var text_field = null setget set_text_field

func _gui_input(event: InputEvent):
	if event.is_action_pressed("mouse_left"):
		_on_close()


func _ready() -> void:
	clopy_btn.disabled = true
	close_btn.connect("pressed", self, "_on_close")
	clopy_btn.connect("pressed", self, "_on_copy")


func _on_copy() -> void:
	OS.clipboard = text_field.text


func _on_close() -> void:
	if text_field:
		_text_attach.remove_child(text_field)
	
	emit_signal("exited")
	
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "rect_scale:y", 1, 0, 0.3, Tween.TRANS_CUBIC)
	tween.interpolate_property(self, "modulate:a", 1, 0, 0.15)
	
	tween.start()
	yield(tween,"tween_all_completed")
	queue_free()


func set_text_field(node: Control) -> void:
	clopy_btn.disabled = true
	if text_field:
		remove_child(text_field)
	if node:
		_text_attach.add_child(node)
		text_field = node
		clopy_btn.disabled = false
		node.grab_focus()


func _enter_tree():
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "rect_scale:y", 0.5, 1, 0.15, Tween.TRANS_CUBIC)
	tween.interpolate_property(self, "modulate:a", 0, 1, 0.15)
	tween.start()
