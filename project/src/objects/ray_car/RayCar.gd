extends RigidBody

export var grounded_threshold = 2

var runner: BoardRunner = null
var _disabled = false

onready var _wheels: Array = [$RightFront, $LeftFront, $RightBack, $LeftBack]


func set_runner(runner: BoardRunner):
	if ! runner:
		return
	runner.connect("status_changed", self, "_on_board_status_changed")
	$Attachments/RayCast.set_boardview(runner.view())


func _integrate_forces(state: PhysicsDirectBodyState) -> void:
	var touching = 0

	# Iterate over our springs so that they can apply their forces
	# Also count if they are touching the ground
	for wheel in _wheels:
		wheel.add_force(state)
		if wheel.is_colliding():
			touching += 1

	# TODO: Have better friction / drag
	# Stupid drag / friction when grounded
	if touching < 2:
		state.add_force(-state.linear_velocity / 3, Vector3.ZERO)
		state.add_torque(-state.angular_velocity / 3)
		return

	state.add_force(-state.linear_velocity, Vector3.ZERO)
	state.add_torque(-state.angular_velocity)

	# Stupid steering
	if Input.is_action_pressed("ui_right"):
		state.add_torque(transform.basis.xform(Vector3.DOWN * 5))
	elif Input.is_action_pressed("ui_left"):
		state.add_torque(transform.basis.xform(Vector3.UP * 5))
	else:
		# Extra extra friction
		state.add_torque(-state.angular_velocity * 3)

	# Stupid throttle
	if Input.is_action_pressed("ui_up"):
		state.add_force(transform.basis.xform(Vector3.FORWARD) * 30, Vector3(0, -0.2, 0))
	elif Input.is_action_pressed("ui_down"):
		state.add_force(transform.basis.xform(Vector3.BACK) * 30, Vector3(0, -0.2, 0))
	else:
		# Extra extra friction
		state.add_force(-state.linear_velocity * 3, Vector3.ZERO)


func _on_board_status_changed(status) -> void:
	if status == SMCE.Status.STOPPED:
		queue_free()  # just die
