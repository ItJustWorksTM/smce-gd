extends Camera


export var enabled = true setget set_enabled, get_enabled
export var speed = 5.0 setget set_speed, get_speed
export var target_path = NodePath("") setget set_target_path, get_target_path
export var offset = Vector3.ZERO
var target = null


func _ready():
	if target_path:
		target = get_node(target_path)
	
func _physics_process(delta):
	if !enabled:
		set_physics_process(false)
	if !target:
		return
	var target_pos = target.global_transform.translated(offset)
	global_transform = global_transform.interpolate_with(target_pos, speed * delta)
	
func get_enabled() -> bool:
	return enabled
	
func set_enabled(value: bool) -> void:
	enabled = value
	set_physics_process(value)
	
func get_speed() -> bool:
	return speed
	
func set_speed(value: float) -> void:
	speed = value
	
func get_target_path() -> NodePath:
	return target_path
	
func set_target_path(value: NodePath) -> void:
	target_path = value
	target = get_node(target_path)
	
func set_target(target: Object) -> void:
	self.target = target
	target_path = get_path_to(target)

