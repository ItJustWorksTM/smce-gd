class_name Lens
extends Observable

var _observable: Observable
var _prop: String

func _init(ob: Observable, prop: String) -> void:
	self._observable = ob
	self._prop = prop
	
	ob.changed.connect(self.emit_change)

func get_value() -> Variant:
	return self._observable.value[self._prop]
