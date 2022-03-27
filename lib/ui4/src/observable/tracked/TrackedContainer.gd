class_name TrackedContainer
extends Tracked

enum { __, INSERTED, ERASED, CLEARED }

func for_each_item(cb: Callable) -> void:
	for i in self._keys():
		cb.call(self.index_item(i))

func find_item(cb: Callable) -> KeyValue:
	for i in self._keys():
		var item = self.index_item(i)
		if cb.call(item):
			return item
	return null

func _keys(): # -> iterable..
	return []

#func erase(key) -> Variant:
#	assert(false)
#	return null
#
#func insert(key, value) -> void:
#	assert(false)

func clear() -> void:
	assert(false)

func size() -> int:
	return 0

func is_empty() -> bool:
	return self.size() == 0

func _to_string():
	var out = ""
	var i = 0
	for k in self._keys():
		var kv = self.index_item(k)
		out += "(%s: %s)" %  [str(kv.k.value), str(kv.v.value)]
		if i + 1 != self.size(): out += ", "
		i += 1
	return "Tracked([%s])" % out
