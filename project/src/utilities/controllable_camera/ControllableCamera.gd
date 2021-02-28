extends Spatial

var rot_x = 0
var rot_y = 0
var LOOKAROUND_SPEED = 0.01

var _disabled = true
var _last_focus_owner: Control = null

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left"):
		if _last_focus_owner:
			_last_focus_owner.release_focus()
		_disabled = false
	elif event.is_action_released("mouse_left"):
		_disabled = true

	if event is InputEventMouseMotion and Input.is_action_pressed("mouse_left") and ! _disabled:
		# modify accumulated mouse rotation
		rot_x -= event.relative.x * LOOKAROUND_SPEED
		rot_y -= event.relative.y * LOOKAROUND_SPEED
		transform.basis = Basis()  # reset rotation
		rotate_object_local(Vector3(0, 1, 0), rot_x)  # first rotate in Y
		rotate_object_local(Vector3(1, 0, 0), rot_y)  # then rotate in X


func _ready():
	get_viewport().connect("gui_focus_changed", self, "_on_focus_owner_changed")

func _on_focus_owner_changed(owner):
	_last_focus_owner = owner

func _process(delta: float) -> void:
	var d = Input.get_action_strength("backward") - Input.get_action_strength("forward")
	var b = Input.get_action_strength("right") - Input.get_action_strength("left")
	var u = Input.get_action_strength("up") - Input.get_action_strength("down")
	var new = Vector3(b, u, d) / 5

	if new != Vector3.ZERO:
		translate(new)

