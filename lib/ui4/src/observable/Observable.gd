class_name Observable

signal changed()

var value: Variant: get = get_value, set = __set_value

func get_value() -> Variant:
	Fn.unreachable()
	return null

func __set_value(__): Fn.unreachable()

func emit_change() -> void:
	self.changed.emit()

func _to_string(): return "Observable(%s)" % str(self.value)
