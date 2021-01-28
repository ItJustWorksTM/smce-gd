class_name BButtonGroup
extends ButtonGroup

var _last_pressed: Button = null
	
func _init():
	for button in get_buttons():
		button.connect("toggled", self, "_on_button_toggle", [button])

func _on_button_toggle(toggle: bool, button: Button):
	if button == _last_pressed:
		button.pressed = false
		_last_pressed = null
	else:
		_last_pressed = button
