extends Camera
func extern_class_name():
	return "InterPolCamera"
	
export(float, 0, 1, 0.1) var transition_speed := 0.5 
export(float, 0, 1, 0.1) var rotation_speed := 0.5

export(NodePath) var target: NodePath

func set_target(node):
	target = node.get_path()

func _physics_process(delta):
	if not has_node(target):
		return

	var local_origin = Transform(Basis(), get_global_transform().origin)
	var local_basis = Transform(get_global_transform().basis, Vector3())
	
	var target_node := get_node(target) as Node
	var target_xform = target_node.get_global_transform()
	
	local_origin = local_origin.interpolate_with(target_xform, transition_speed)
	local_basis = local_basis.interpolate_with(target_xform, rotation_speed)
	set_global_transform(Transform(local_basis.basis, local_origin.origin))



