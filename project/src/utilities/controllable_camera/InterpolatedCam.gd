#
#  InterpolatedCam.gd
#  
#  Made by group 13


extends Camera

export (float) var speed = 4.0 
export (NodePath) var target = NodePath("") setget set_target

func _ready():
	if ! get_path():
		return 


func set_target(targ: Spatial) -> void:
	target = get_path_to(targ)

# Use more error checking with enabled and such
func _physics_process(delta) -> void:
	if ! target:
		return
	var node = get_node(target)

	# if disabled:
	# 	set_physics_process(false)
	
	# if FocusOwner.has_focus():
		# return
	
	var d = Input.get_action_strength("backward") - Input.get_action_strength("forward")
	var b = Input.get_action_strength("right") - Input.get_action_strength("left")
	var u = Input.get_action_strength("up") - Input.get_action_strength("down")
	var new = Vector3(b, 0, d) / 5
	var up = Vector3(0, u, 0) / 5
	
	
	# if new != Vector3.ZERO:
	# 	translate(new)

	# global_translate(up)

	# print(near)
	# print(far)
	# print(current)
	# print(transform)
	# print(target)
	# print(speed)
	

	var target_xform = node.get_global_transform()
	var local_transform = get_global_transform()
	local_transform = local_transform.interpolate_with(target_xform, speed * delta)
	set_global_transform(local_transform)
	var cam := node as Camera
	if (cam):
		if (cam.get_projection() == get_projection()):
			if (cam.get_projection() == PROJECTION_ORTHOGONAL):
				var size = lerp(get_size(), cam.get_size(), speed * delta)
				set_orthogonal(size, near, far)
			else:
				var fov = lerp(get_fov(), cam.get_fov(), speed * delta)
				set_perspective(fov, near, far)
	
