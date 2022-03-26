class_name TrackedVec
extends Observable
var inner: Array = []

# TODO: extract mutatable into a derived class so that we can make transforms

enum { INSERT, REMOVED, MODIFIED, CLEAR }
signal vec_changed(type, index)

func _init(v = []):
	self.append_array(v)

func get_value():
	return self

func _emit_change(type, i):
	self.vec_changed.emit(type, i)
	self.emit_change()

func remove(i: int) -> Variant:
	var ret = self.inner[i]

	self.inner.remove_at(i)
	
	for j in self.size() - i:
		self.inner[i+j][1].value -= 1
	
	
	ret[1].value = -1
	self._emit_change(REMOVED, i)
	
	
	return ret

func insert(i, v: Variant) -> void:
	
	self.inner.insert(i, [ObservableValue.new(v), ObservableValue.new(i)])
	
	for j in self.size() - i - 1:
		self.inner[i + j + 1][1].value += 1
	
	self._emit_change(INSERT, i)

func push(v: Variant) -> void:
	self.insert(self.size(), v)

func pop() -> Variant:
	assert(!self.is_empty())
	return self.remove(self.size()-1)

func size() -> int: return inner.size()

func clear() -> void:
	var cleared = size()
	self.inner.clear()
	self._emit_change(CLEAR, cleared)

func append_array(arr: Array[Variant]) -> void:
	for k in arr:
		self.push(k)

func index(i: int) -> Variant:
	assert(i >= 0 && i < self.size(), "out of bounds")
	return self.inner[i][0].value

func index_r(i: int) -> Array:
	return self.inner[i]

func index_mut(i: int, cb: Callable) -> void:
	self.inner[i][0].value = cb.call(self.index(i))
	self._emit_change(MODIFIED, i)

# algorithms
func each(cb: Callable) -> void:
	for i in self.inner.size():
		cb.call(self.index(i), i)

func each_r(cb: Callable) -> void:
	for i in self.inner.size():
		var tmp = self.index_r(i)
		assert(not tmp[1] is int)
		cb.call(tmp[0], tmp[1])

func find(cb: Callable) -> Variant:
	for i in self.inner.size():
		if cb.call(self.index(i)):
			return self.index(i)
	return null

func is_empty() -> bool:
	return self.size() == 0

func _to_string():
	var out = ""
	for i in self.size():
		out += str(self.index(i))
		if i + 1 != self.size(): out += ", "
	return "TrackedVec([%s])" % out
