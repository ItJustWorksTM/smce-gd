extends Node

export var main_scene: PackedScene = null

onready var _header: Label = $Header
onready var _log: RichTextLabel = $Log
onready var _button: Button = $Button

var error: String = ""

func _ready():
	_button.connect("pressed", self, "_on_clipboard_copy")

	print("User dir: ", OS.get_user_data_dir())

	var dir = Directory.new()
	if dir.open("res://share/RtResources"):
		return _error("RtResources not found!")

	if ! Util.copy_dir("res://share/RtResources", "user://RtResources"):
		return _error("Failed to copy in RtResources")

	if ! Util.copy_dir("res://share/library_patches", "user://library_patches"):
		return _error("Failed to copy in library_patches")

	print("Copied RtResources")

	var bar = BoardRunner.new()
	if bar == null:
		return _error("Shared library not loaded")
	bar.free()
	
	_continue()


func _continue():
	if ! main_scene:
		return _error("No Main Scene")
	get_tree().change_scene_to(main_scene)


func _error(message: String) -> void:
	var file: File = File.new()
	var result = file.open("user://logs/godot.log", File.READ)
	var logfile = file.get_as_text()
	file.close()

	_log.text = logfile
	_header.text += "\n" + message
	error = "Error Reason: " + message + "\n" + logfile


func _on_clipboard_copy() -> void:
	OS.clipboard = error
