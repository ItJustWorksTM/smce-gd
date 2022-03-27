class_name TrackedMapped
extends TrackedContainer

var _inner: TrackedContainer
var _transform: Callable

var _cache := {}

func _init(inner: TrackedContainer, transform: Callable) -> void:
	_inner = inner
	_transform = transform
	
	var this = self
	inner.for_each_item(func(vi): this._update(INSERTED, vi.key.value))
	_inner.item_changed.connect(self._update)

func _update(ty, i) -> void:
	match ty:
		INSERTED:
			var vi := self._inner.index_item(i)
			var mapped = Mapped.new(vi.v, self._transform)
			mapped.changed.connect(self._mapped_changed.bind(vi.k))
			_cache[vi.k] = [vi.k, mapped]
		ERASED:
			for a in self._cache.keys():
				if a.value == null:
					Reflect.distconnect_all(self, self._cache[a][1].changed)
					self._cache.erase(a)
					break
		CLEARED:
			for cleared in i:
				for a in self._cache.keys():
					if a.value == null:
						self._cache.erase(a)
						break
		MODIFIED:
			return
	emit_item_change(ty, i)

func _mapped_changed(index):
	emit_item_change(MODIFIED, index.value)

func size() -> int:
	return _inner.size()

func _keys():
	return _inner._keys()

func index_item(key):
	var n = self._cache[self._inner.index_item(key).k]
	return KeyValue.new(n[0], n[1])
