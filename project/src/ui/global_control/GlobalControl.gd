extends Control

signal do_compile(path)

onready var ltop: HBoxContainer = $LeftTop/HBoxContainer
onready var options: Button = ltop.get_node("Options")
onready var compile: Button = ltop.get_node("Compile")
onready var sketches: Button = ltop.get_node("Sketches")
onready var world: Button = ltop.get_node("World")
onready var buttons: BButtonGroup = options.group

onready var file_picker = $FilePicker


func _ready() -> void:
	buttons._init()

	file_picker.connect("file_selected", self, "_on_file_picked")

	options.connect("toggled", self, "_on_options_toggeld")
	compile.connect("toggled", self, "_transition_window", [file_picker])


func _on_file_picked(path: String):
	print("compiling:", path)
	emit_signal("do_compile", path)
	_transition_window(true, file_picker)
	compile.pressed = false


func _on_options_toggeld(toggle: bool):
	print("pressed options")


func _transition_window(toggled: bool, node: Control) -> void:
	var owner = get_focus_owner()
	if owner:
		owner.release_focus()
	if ! node.visible and toggled:
		node.rect_scale.y = 0
		node.modulate.a = 0
	node.visible = toggled
	ControlUtil.toggle_window(toggled, node)
