class_name Mapped
extends Observable

var _observable: Observable
var _transform: Callable

var _cache: Variant

func _init(observable: Observable, transform: Callable) -> void:
	self._observable = observable
	self._transform = transform
	self._observable.changed.connect(self._update)
	self._update()

func _update() -> void:
	_cache = _transform.call(self._observable.value)
	emit_change()

func get_value() -> Variant:
	return self._cache

func set_value(v: Variant) -> void:
	assert(not v is Object, "Mapped values cannot be modified") # maybe also dicts / arrays?
