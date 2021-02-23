tool
extends VBoxContainer

export var heading_text: String = "Collapsable" setget set_header_text

onready var header: Button = $Button
onready var icon: Label = $Button/Icon


func set_header_text(text: String) -> void:
	heading_text = text
	if header:
		header.text = text
		_update_icon(header.pressed)


func _update_icon(pressed: bool) -> void:
	if ! icon:
		return

	if pressed:
		icon.text = "v"
	else:
		icon.text = ">"


func _ready() -> void:
	_update_icon(false)
	header.text = heading_text
	_on_header_pressed(header.pressed)
	header.connect("toggled", self, "_on_header_pressed")


func _on_header_pressed(pressed: bool) -> void:
	_update_icon(pressed)
	for child in get_children():
		if child != header:
			child.visible = pressed
