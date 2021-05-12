extends RigidBody
class_name RayCar
func extern_class_name():
	return "RayCar"


export(Array, NodePath) onready var cosmetic_wheels
onready var _cosmetic_wheels: Array = []

var _wheels: Array = []

export(Array, NodePath) onready var right_wheels
onready var _rightw: Array = []

export(Array, NodePath) onready var left_wheels
onready var _leftw: Array = []

export(NodePath) onready var left_motor
onready var lmotor: BrushedMotor = get_node_or_null(left_motor)

export(NodePath) onready var right_motor
onready var rmotor: BrushedMotor = get_node_or_null(right_motor)

onready var attachments: Array = []
onready var attachment_slots: Array = []
onready var builtin_attachments: Array = []

var frozen = false
var _view = null


func set_view(view):
	_view = view
	for attach in attachments:
		if attach.has_method("set_view"):
			attach.set_view(view)


func add_aux_attachment(slot_name: String, attachment: Node) -> GDResult:
	for slot in attachment_slots:
		if slot.name == slot_name:
			if slot.get_child_count() > 0:
				return Util.err("Slot already has attachment")
			
			slot.add_child(attachment, true)
			
			attachment.set_view(_view)
			attachments.push_back(attachment)
			return GDResult.new()
	return Util.err("Slot not found")


func get_nodes(node_paths: Array) -> Array:
	var ret: Array = []
	
	for node_path in node_paths:
		ret.push_back(get_node(node_path))
	
	return ret


func _ready():
	_cosmetic_wheels = get_nodes(cosmetic_wheels)
	_rightw = get_nodes(right_wheels)
	_leftw = get_nodes(left_wheels)
	_wheels = _rightw + _leftw
	
	if get_node_or_null("BuiltinAttachments"):
		attachments += $BuiltinAttachments.get_children()
	if get_node_or_null("AttachmentSlots"):
		attachment_slots += $AttachmentSlots.get_children()
	
	for slot in attachment_slots:
		attachments += slot.get_children()


func freeze() -> void:
	mode = RigidBody.MODE_STATIC
	frozen = true


func unfreeze() -> void:
	mode = RigidBody.MODE_RIGID
	frozen = false
	# Trick the wheels to think they have not moved since last frame
	# so that velocity calculation dont freak out in case
	# we have been moved since
	for wheel in _wheels:
		wheel.prev_pos = wheel.global_transform.origin


func _integrate_forces(state: PhysicsDirectBodyState) -> void:
	var key_direction: int = (
		int(Input.is_action_pressed("ui_up"))
		- int(Input.is_action_pressed("ui_down"))
	)
	
	for wheel in _rightw:
		if _view:
			if is_instance_valid(rmotor):
				wheel.throttle = rmotor.get_speed()
		else:
			wheel.throttle = 1 * key_direction * int(! Input.is_action_pressed("ui_right"))

	for wheel in _leftw:
		if _view:
			if is_instance_valid(lmotor):
				wheel.throttle = lmotor.get_speed()
		else:
			wheel.throttle = 1 * key_direction * int(! Input.is_action_pressed("ui_left"))
	
	for wheel in _wheels:
		wheel.add_force(state)
	
	assert(_cosmetic_wheels.size() <= _wheels.size())
	for i in range(_cosmetic_wheels.size()):
		var wheel: Spatial = _cosmetic_wheels[i]
		if _wheels[i].is_colliding():
			wheel.global_transform.origin = _wheels[i].get_collision_point()
			wheel.transform.origin *= Vector3(0,1,0)
		for child in wheel.get_children():
			child.rotate(Vector3(1,0,0), _wheels[i].throttle * PI/5)

