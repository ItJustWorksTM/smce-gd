extends VBoxContainer

export (int) var max_text = 1000

var disabled: bool = true setget set_disabled
var runner: BoardRunner = null setget set_runner
var uart_channel: int = 0 setget set_uart_channel

onready var header: Label = $Header
onready var console: RichTextLabel = $Console
onready var input: LineEdit = $Input


func set_disabled(val: bool) -> void:
	disabled = val
	input.editable = ! val


func set_runner(new_runner) -> void:
	if runner:
		runner.disconnect("status_changed", self, "_on_board_status_changed")
	runner = new_runner
	runner.connect("status_changed", self, "_on_board_status_changed")
	runner.uart().connect("uart", self, "_on_uart")
	_on_board_status_changed(runner.status())
	set_uart_channel(0)


func set_uart_channel(val: int) -> void:
	uart_channel = -1
	if runner and runner.uart() and val < runner.uart().channels():  # muh shortcircuit??
		uart_channel = val
	header.text = "Uart | " + str(uart_channel)
	console.clear()
	input.clear()


func _ready() -> void:
	input.connect("gui_input", self, "_on_input")
	set_process(false)


func _on_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and input.text != "" and runner:
		if ! runner.uart().write(uart_channel, input.text):
			print("failed to write to uart channel", uart_channel)
		input.text = ""


func _on_uart(channel, text) -> void:
	console.add_text(text)
	if console.text.length() > max_text:
		console.text = console.text.substr(console.text.length() - max_text)


func _on_board_status_changed(status: int) -> void:
	set_disabled(! (status == SMCE.Status.RUNNING || status == SMCE.Status.SUSPENDED))
	if status == SMCE.Status.STOPPED:
		runner = null
