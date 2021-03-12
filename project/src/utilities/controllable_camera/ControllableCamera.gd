extends Spatial

var rot_x = 0
var rot_y = 0
var LOOKAROUND_SPEED = 0.01

var _disabled = true
var _last_focus_owner: Control = null

onready var _focus_check: Control = Control.new()
func _no_focus() -> bool:
	return _focus_check.get_focus_owner() == null

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left"):
		var fcs = _focus_check.get_focus_owner()
		if fcs:
			fcs.release_focus()
		
	if event is InputEventMouseMotion and Input.is_action_pressed("mouse_left") and _no_focus():
		# modify accumulated mouse rotation
		rot_x -= event.relative.x * LOOKAROUND_SPEED
		rot_y -= event.relative.y * LOOKAROUND_SPEED
		transform.basis = Basis()  # reset rotation
		rotate_object_local(Vector3(0, 1, 0), rot_x)  # first rotate in Y
		rotate_object_local(Vector3(1, 0, 0), rot_y)  # then rotate in X


func _ready():
	add_child(_focus_check)


func _process(delta: float) -> void:
	if ! _no_focus():
		return
	var d = Input.get_action_strength("backward") - Input.get_action_strength("forward")
	var b = Input.get_action_strength("right") - Input.get_action_strength("left")
	var u = Input.get_action_strength("up") - Input.get_action_strength("down")
	var new = Vector3(b, u, d) / 5

	if new != Vector3.ZERO:
		translate(new)
