class_name Combined
extends Observable

var _observables: Array

var _cache: Variant

func _init(observables: Array) -> void:
	self._observables = observables
	for o in observables:
		o.changed.connect(self._update)
	
	self._update()

func _update() -> void:
	_cache = []
	for o in self._observables:
		_cache.push_back(o.value)
	emit_change()

func get_value() -> Variant:
	return self._cache

