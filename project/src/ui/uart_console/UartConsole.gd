#
#  UartConsole.gd
#  Copyright 2022 ItJustWorksTM
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

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

