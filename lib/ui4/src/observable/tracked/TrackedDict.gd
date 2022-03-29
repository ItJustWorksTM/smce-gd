class_name TrackedDict
extends TrackedContainer

var _obs := {}

func _init() -> void:
    pass

func index_item(key: Variant) -> KeyValue:
    return _setup_link(key, KeyValue)

func index_item_mut(key: Variant) -> KeyValueMut:
    return _setup_link(key, KeyValueMut)

func has(key: Variant) -> bool:
    return key in self._obs

func erase(key):
    var item = self.index_item(key)
    
    Reflect.distconnect_all(self, item.v.changed)
    
    item.k.value = null
    
    self._obs.erase(key)
    emit_item_change(ERASED, key)

func insert(key, value) -> void:
    if key in self._obs:
        self.index_item_mut(key).v.value = value
    else:
        var val = ObservableValue.new(value)
        self._obs[key] = [ObservableValue.new(key), val]
        val.changed.connect(self._update.bind(key))
        
        emit_item_change(INSERTED, key)

func _setup_link(key: Variant, type):
    if !(key in self._obs):
        assert(false)
    var kv = type.new(self._obs[key][0], self._obs[key][1])
    return kv

func size() -> int:
    return self._obs.size()

func clear() -> void:
    var cleared = self._keys()
    self._obs.clear()
    self.emit_item_change(CLEARED, cleared)

func _keys():
    return self._obs.keys()

func _update(key):
    emit_item_change(Tracked.MODIFIED, key)
