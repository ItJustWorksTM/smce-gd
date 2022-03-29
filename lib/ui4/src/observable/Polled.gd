class_name Polled
extends Observable

var _period: float
var _obj: Object
var _prop: String

var _value: Variant


func _init(obj: Object, prop: String, period: float = 0.2):
	_period = period
	_obj = obj
	_prop = prop
	
	_update()

func _update():
	
	_value = _obj.get_indexed(_prop)
	emit_change()
	
	var tree := Engine.get_main_loop() as SceneTree
	assert(tree)
	tree.create_timer(_period).timeout.connect(self._update)

func get_value() -> Variant:
	return _value
