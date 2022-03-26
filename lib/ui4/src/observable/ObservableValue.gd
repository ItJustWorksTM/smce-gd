class_name ObservableValue
extends ObservableMut

var _value: Variant = null

func _init(v: Variant = null):
	self._value = v

func get_value() -> Variant:
	return self._value

func set_value(v: Variant) -> void:
	self._value = v
	self.emit_change()
