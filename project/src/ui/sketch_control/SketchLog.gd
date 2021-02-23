extends PanelContainer

onready var copy_clipboard_btn = $VBoxContainer/HBoxContainer/Copy
onready var log_box = $VBoxContainer/LogBox

func _ready() -> void:
	copy_clipboard_btn.connect("pressed", self, "_on_copy_pressed")

func _on_copy_pressed() -> void:
	OS.clipboard = log_box.text
