class_name InnerMut
extends ObservableMut

var _observable: ObservableMut

func _init(ob: ObservableMut) -> void:
	self._observable = ob
	
	ob.changed.connect(self.emit_change)

func get_value() -> Variant:
	return self._observable.value.value

func set_value(val: Variant) -> void:
	self._observable.value.value = val
