extends VBoxContainer

export (int) var max_text = 1000

var disabled: bool = true setget set_disabled
var uart_channel: int = 0 setget set_uart_channel

onready var header: Label = $Header
onready var console: RichTextLabel = $Console
onready var input: LineEdit = $Input

var _uart = null

func set_disabled(val: bool) -> void:
	disabled = val
	input.editable = ! val

func set_uart(uart) -> void:
	if _uart:
		_uart.disconnect("uart", self, "_on_uart")
	uart.connect("uart", self, "_on_uart")
	_uart = uart
	set_uart_channel(0)


func set_uart_channel(val: int) -> void:
	if _uart and val < _uart.channels():
		uart_channel = val
	header.text = "Uart | " + str(uart_channel)
	console.clear()
	input.clear()


func _ready() -> void:
	input.connect("gui_input", self, "_on_input")
	set_process(false)


func _on_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and input.text != "" and _uart:
		var res = _uart.write(uart_channel, input.text)
		if ! res.ok():
			print("failed to write to uart channel %d: %s" % [uart_channel, res.error()])
		input.text = ""


func _on_uart(channel, text) -> void:
	console.add_text(text)
	if console.text.length() > max_text:
		console.text = console.text.substr(console.text.length() - max_text)

