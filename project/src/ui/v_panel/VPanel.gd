tool
extends PanelContainer


enum SIDE { LEFT, RIGHT }
export(SIDE) var side = SIDE.LEFT setget set_side
func set_side(nside) -> void:
	side = nside
	if side == SIDE.LEFT:
		get_stylebox("panel").border_width_left = 8
		get_stylebox("panel").border_width_right = 0
	elif side == SIDE.RIGHT:
		get_stylebox("panel").border_width_left = 0
		get_stylebox("panel").border_width_right = 8

func _ready():
	add_stylebox_override("panel", get_stylebox("panel").duplicate(true))
	pass # Replace with function body.

