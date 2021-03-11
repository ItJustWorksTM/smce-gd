extends RigidBody

var runner: BoardRunner = null
var _disabled: bool = false

onready var _wheels: Array = [$RightFront, $LeftFront, $RightBack, $LeftBack]
onready var _cosmetic_wheels: Array = [
	$RightFront/wheel, $LeftFront/wheel, $RightBack/wheel, $LeftBack/wheel
]

onready var _rightw: Array = [$RightFront, $RightBack]
onready var _leftw: Array = [$LeftFront, $LeftBack]

onready var lmotor: BrushedMotorGD = $Attachments/LeftMotor
onready var rmotor: BrushedMotorGD = $Attachments/RightMotor
onready var lodo = $Attachments/LeftOdometer
onready var rodo = $Attachments/RightOdometer

onready var attachments: Array = $Attachments.get_children()

func set_runner(_runner: BoardRunner):
	if ! _runner:
		return
	runner = _runner
	runner.connect("status_changed", self, "_on_board_status_changed")
	
	for attach in attachments:
		if attach.has_method("set_view"):
			attach.set_view(runner.view())


func _ready():
	lodo.forward_reference = self
	rodo.forward_reference = self


func freeze() -> void:
	mode = RigidBody.MODE_STATIC


func unfreeze() -> void:
	mode = RigidBody.MODE_RIGID
	# Trick the wheels to think they have not moved since last frame
	# so that velocity calculation dont freak out in case
	# we have been moved since
	for i in range(_wheels.size()):
		_wheels[i].prev_pos = _wheels[i].global_transform.origin


func _process(delta):
	$SpotLight.light_color.h += delta * 0.1


func _integrate_forces(state: PhysicsDirectBodyState) -> void:
	for i in range(_wheels.size()):
		_wheels[i].add_force(state)
		if _wheels[i].is_colliding():
			_cosmetic_wheels[i].global_transform.origin = _wheels[i].get_collision_point()

	var key_direction: int = (
		int(Input.is_action_pressed("ui_up"))
		- int(Input.is_action_pressed("ui_down"))
	)

	for wheel in _rightw:
		if runner:
			wheel.throttle = lmotor.get_speed()
		else:
			wheel.throttle = key_direction * int(! Input.is_action_pressed("ui_right"))

	for wheel in _leftw:
		if runner:
			wheel.throttle = rmotor.get_speed()
		else:
			wheel.throttle = key_direction * int(! Input.is_action_pressed("ui_left"))


func _on_board_status_changed(status) -> void:
	if status == SMCE.Status.STOPPED:
		queue_free()  # just die
