class_name ObservableMut
extends Observable

func __set_value(value: Variant) -> void: set_value(value)

func set_value(value: Variant) -> void: Fn.unreachable()

func mutate(cb: Callable) -> void:
	if self.value is Object || self.value is Dictionary:
		cb.call(self.value)
		self.set_value(self.value)
	else:
		self.set_value(cb.call(self.value))
