extends Spatial

var _prev_pos: Vector3
var traveled: float = 0

func _ready() -> void:
	_prev_pos = global_transform.origin

func _process(delta: float) -> void:
	var pos: Vector3 = global_transform.origin
	traveled += pos.distance_to(_prev_pos)
	_prev_pos = pos

