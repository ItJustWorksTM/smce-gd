class_name TrackedVec
extends TrackedContainer

var inner: Array = []

func _init(v = []):
	self.append_array(v)

func erase(i: int):
	var ret = self.inner[i]
	
	var disc: ObservableValue = ret[0]

	Reflect.distconnect_all(self, disc.changed)
	
	self.inner.remove_at(i)
	
	for j in self.size() - i:
		self.inner[i+j][1].value -= 1
	
	ret[1].value = null
	
	self.emit_item_change(ERASED, i)

func insert(i, v: Variant) -> KeyValueMut:
	var value_ob = ObservableValue.new(v)
	value_ob.changed.connect(self._item_modified.bind(i))
	self.inner.insert(i, [value_ob, ObservableValue.new(i)])
	
	for j in self.size() - i - 1:
		self.inner[i + j + 1][1].value += 1
	
	self.emit_item_change(INSERTED, i)
	
	return self.index_item_mut(i)

func _item_modified(i) -> void:
	self.emit_item_change(MODIFIED, i)


func index_item(i) -> KeyValue:
	return KeyValue.new(self.inner[i][1], self.inner[i][0])

func index_item_mut(i) -> KeyValueMut:
	return KeyValueMut.new(self.inner[i][1], self.inner[i][0])

func size() -> int: return inner.size()

func _keys(): return self.size()

func clear() -> void:
	var cleared = self.size()
	self.inner.clear()
	self.emit_item_change(CLEARED, cleared)

func push(v: Variant) -> void:
	self.insert(self.size(), v)

func append_array(arr: Array[Variant]) -> void:
	for k in arr:
		self.push(k)

func pop() -> Variant:
	assert(!self.is_empty())
	return self.remove(self.size()-1)

func index(i: int) -> Variant:
	assert(i >= 0 && i < self.size(), "out of bounds")
	return self.inner[i][0].value


