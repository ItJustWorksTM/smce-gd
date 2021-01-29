extends RayCast

var max_hit_distance = abs(cast_to.y)
var prev_contact_depth = max_hit_distance

export (float, 1, 20, 0.1) var spring_force = 10
export (float, 1, 20, 0.1) var damper_force = 1
export (float, 0, 2, 0.1) var target = 0.6


func add_force(state: PhysicsDirectBodyState):
	if is_colliding():
		var parent = get_parent()
		var point = get_collision_point()
		point.x = global_transform.origin.x
		point.z = global_transform.origin.z

		# Either point up to the sky or follow the surface normal
		# Pointing up has to effect of sticking to slanted surfaces better
		#var normal = get_collision_normal()
		var normal = Vector3.UP

		var distance = point.distance_to(global_transform.origin)
		var contact_depth = max_hit_distance - distance
		var velocity = (prev_contact_depth - contact_depth) / state.step
		prev_contact_depth = contact_depth

		var s_force = contact_depth * spring_force
		var d_force = velocity * damper_force
		var force = (
			-spring_force * (abs(distance) - target) * (distance / abs(distance))
			- damper_force * velocity
		)

		if force < 0:
			return

		var real_force = normal * force
		var force_position = global_transform.origin - parent.global_transform.origin
		state.add_force(real_force, force_position)

		# debug
		if ! DebugCanvas.disabled:
			var pos = global_transform.origin
			DebugCanvas.add_draw(pos, pos + real_force, Color(1, 0, 0, 0.5))
			DebugCanvas.add_draw(pos, point, Color(0, 0, 1, 0.5))
