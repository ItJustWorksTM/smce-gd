class_name Tracked
extends Observable

enum { MODIFIED }

signal item_changed(how, what)

func emit_item_change(how: int, what):
	self.item_changed.emit(how, what)
	emit_change()

func index_item(key: Variant) -> KeyValue:
	assert(false)
	return null

func index_item_mut(key: Variant) -> KeyValueMut:
	assert(false)
	return null

func mutate_item(key: Variant, cb: Callable) -> void:
	var v = index_item_mut(key).v
	v.value = cb.call(v.value)

func has(key: Variant) -> bool:
	return false

func get_value() -> Variant:
	return self # we are the value

func _to_string(): return "Tracked(...)"
