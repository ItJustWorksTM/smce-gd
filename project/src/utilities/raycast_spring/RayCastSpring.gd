extends RayCast

var max_hit_distance: float = abs(cast_to.y)
var prev_contact_depth: float = max_hit_distance

onready var prev_pos: Vector3 = global_transform.origin

var prev_sped: float = 0
export (float, 0.1, 100, 0.1) var spring_force = 10
export (float, 0.1, 100, 0.1) var damper_force = 1
export (float, 0, 2, 0.1) var target = 0.6
export (float, 0, 30, 0.1) var max_force = 10

export (float, 0, 100, 1) var motor_force = 5
export (float, -1, 1, 0.01) var throttle = 0

onready var _parent: RigidBody = get_parent()

onready var _force_pos: Vector3 = Vector3.ZERO


func set_force(ratio: float) -> void:
	throttle = min(1, max(0, ratio))


func add_force(state: PhysicsDirectBodyState) -> void:
	_force_pos = global_transform.origin - _parent.global_transform.origin
	_spring_force(state)
	_friction_force(state)
	_motor_force(state)
	prev_pos = global_transform.origin


func _motor_force(state: PhysicsDirectBodyState) -> void:
	if ! is_colliding() || throttle == 0:
		return

	# TODO: get forward direction from ground plane (collision normal)
	var direction: Vector3 = _parent.transform.basis.xform(Vector3.FORWARD)

	var fmotor: Vector3 = direction * motor_force * throttle
	state.add_force(fmotor, _force_pos)

	if ! DebugCanvas.disabled:
		var pos: Vector3 = global_transform.origin
		DebugCanvas.add_draw(pos, pos + fmotor, Color.darkblue)


func _spring_force(state: PhysicsDirectBodyState):
	if ! is_colliding():
		return

	var point: Vector3 = get_collision_point()
	var normal: Vector3 = get_collision_normal()

	point.x = global_transform.origin.x
	point.z = global_transform.origin.z

	var distance: float = point.distance_to(global_transform.origin)
	var contact_depth: float = max_hit_distance - distance

	var velocity: float = (prev_contact_depth - contact_depth) / state.step
	prev_contact_depth = contact_depth

	var s_force: float = contact_depth * spring_force
	var d_force: float = velocity * damper_force
	var force = 0
	if distance != 0:
		force = (
			-spring_force * (abs(distance) - target) * (distance / abs(distance))
			- damper_force * velocity
		)

	force = clamp(force, 0, max_force)

	var real_force: Vector3 = normal * force
	state.add_force(real_force, _force_pos)

	# debug
	if ! DebugCanvas.disabled:
		var pos: Vector3 = global_transform.origin
		DebugCanvas.add_draw(pos, pos + real_force, Color(1, 0, 0, 0.5))
		DebugCanvas.add_draw(pos, point, Color(0, 0, 1, 0.5))


func _friction_force(state: PhysicsDirectBodyState) -> void:
	var pos = global_transform.origin

	var v: Vector3 = (global_transform.origin - prev_pos) / state.step
	var speed: float = sqrt(v.x * v.x + v.z * v.z)

	# Air drag
	var Cdrag: float = 0.005
	var fdrag: Vector3 = Vector3.ZERO
	fdrag.x = -Cdrag * v.x * speed
	fdrag.z = -Cdrag * v.z * speed

	state.add_force(fdrag, _force_pos)

	if ! is_colliding():
		return

	# Rolling resistance
	var Crr: float = 0.05
	var frolling: Vector3 = -Crr * v * Vector3(1, 0, 1)
	state.add_force(frolling, _force_pos)

	if ! DebugCanvas.disabled:
		DebugCanvas.add_draw(pos, pos + frolling, Color.orange)
		DebugCanvas.add_draw(pos, pos + fdrag, Color.yellow)

	# Tracktion
	var Ctt: float = (1 - abs(throttle)) * 2
	var ftraction: Vector3 = -Ctt * v.normalized() * min(4, speed)
	state.add_force(ftraction, _force_pos)

	if ! DebugCanvas.disabled:
		DebugCanvas.add_draw(pos, pos + ftraction, Color.orange)

	# TODO: Make it suck less
	# Anti drifting
	var fwd: Vector3 = _parent.transform.basis.xform(Vector3.FORWARD)
	var left: Vector3 = _parent.transform.basis.xform(Vector3.LEFT)

	v.y = 0
	var left_angle: float = v.normalized().dot(left.normalized())
	var forward_angle: float = v.normalized().dot(fwd.normalized())

	var anglee: float = 1 - abs(forward_angle)

	# -1 is left 1 is right
	if left_angle == 0 || forward_angle == 0:
		return

	var dirr: int = left_angle / abs(left_angle)

	var freal: Vector3 = left * anglee * dirr * -speed
	state.add_force(freal, _force_pos)

	if ! DebugCanvas.disabled:
		DebugCanvas.add_draw(pos, pos + freal, Color.azure)
