extends Spatial

export var disabled = false setget set_disabled

var lookaround_speed = 0.01

export(int, 0, 90) var y_angle_limit = 20 setget set_y_angle_limit
var _y_angle_limit = 0
func set_y_angle_limit(limit: float) -> void:
	_y_angle_limit = range_lerp(limit, 0, 90, 0, PI/2)
	y_angle_limit = y_angle_limit
	_update_pos()

var rot_x = 0
var rot_y = 0

func set_disabled(_disabled: bool) -> void:
	set_physics_process(! _disabled)
	disabled = _disabled


func _unhandled_input(event) -> void:
	if event is InputEventMouseMotion and Input.is_action_pressed("mouse_left") and ! FocusOwner.has_focus():

		rot_x -= event.relative.x * lookaround_speed
		rot_y -= event.relative.y * lookaround_speed
		_update_pos()


func _update_pos():
	rot_y = clamp(rot_y, _y_angle_limit, PI - _y_angle_limit)
	transform.basis = Basis(Quat(Vector3(rot_y - PI /2, rot_x, 0)))


func _physics_process(delta: float) -> void:
	if disabled:
		set_physics_process(false)
	
	if FocusOwner.has_focus():
		return
	
	var d = Input.get_action_strength("backward") - Input.get_action_strength("forward")
	var b = Input.get_action_strength("right") - Input.get_action_strength("left")
	var u = Input.get_action_strength("up") - Input.get_action_strength("down")
	var new = Vector3(b, 0, d) / 5
	var up = Vector3(0, u, 0) / 5
	
	
	if new != Vector3.ZERO:
		translate(new)

	global_translate(up)
