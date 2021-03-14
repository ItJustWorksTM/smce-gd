class_name ShootyVisualizer
extends Button

var _shooty = null

func display_shooty(shooty) -> bool:
	if ! shooty:
		return false
	_shooty = shooty
	connect("pressed", shooty, "shoot")
	set_process(true)
	return true

func _process(_delta: float) -> void:
	if ! _shooty:
		set_process(false)
		return

	var cooldown = _shooty.cooldown()
	disabled = cooldown > 0
	text = "Ready" if cooldown == 0 else "Cooldown: %.2f" % [cooldown]
