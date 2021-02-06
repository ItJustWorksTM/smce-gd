extends Control

onready var top: HBoxContainer = $RightTop/HBoxContainer

onready var attachments: Button = top.get_node("Attachments")
onready var actions: Button = top.get_node("Actions")
onready var uart: Button = top.get_node("Uart")
onready var control: Button = top.get_node("Control")
onready var info: Button = top.get_node("Info")
onready var buttons: BButtonGroup = info.group

onready var uart_window: PanelContainer = $Uart
onready var control_window: PanelContainer = $Control

onready var uart_ctl: VBoxContainer = $Uart/Uart
onready var sketch_ctl: VBoxContainer = $Control/SketchControl

var runner: BoardRunner = null setget set_runner


func set_runner(new_board: BoardRunner) -> void:
	runner = new_board
	sketch_ctl.runner = new_board
	uart_ctl.runner = new_board


func _ready() -> void:
	buttons._init()
	uart.connect("toggled", self, "_transition_window", [uart_window])
	control.connect("toggled", self, "_transition_window", [control_window])


func _transition_window(toggled: bool, node: Control) -> void:
	var owner = get_focus_owner()
	if owner:
		owner.release_focus()

	if ! node.visible and toggled:
		node.rect_scale.y = 0
		node.modulate.a = 0

	node.visible = toggled
	ControlUtil.toggle_window(toggled, node)
