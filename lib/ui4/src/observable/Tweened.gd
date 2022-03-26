class_name Tweened
extends Observable

var _observable: Observable
var _tween: Tween

var __value: Variant
var _value: Variant:
	set = _set_value,
	get = _get_value

func _get_value() -> Variant:
	return __value

func _set_value(v: Variant) -> void:
	__value = v
	emit_change()

var _speed: float
var _trans: Tween.TransitionType

func _init(ob: Observable, speed: float, trans: Tween.TransitionType = 0) -> void:
	self._observable = ob
	self._speed = speed
	self._trans = trans
	self.__value = ob.value
	
	ob.changed.connect(self._update)
	
	_update()

func _update():
	if is_instance_valid(_tween):
		_tween.stop()
		_tween = null
	elif self.value == self._observable.value:
		return
	
	var tree := Engine.get_main_loop() as SceneTree
	assert(tree)
	
	var new_target = self._observable.value

	_tween = tree.create_tween()
	_tween.tween_property(self, "_value", new_target, self._speed)
	_tween.play()

func get_value(): return self._value
