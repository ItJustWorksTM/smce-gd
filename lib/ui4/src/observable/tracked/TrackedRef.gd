class_name TrackedRef
extends Tracked

var _inner: RefCounted

var _obs := {}

func _init(ref: RefCounted) -> void:
    self._inner = ref

func index_item(key: Variant) -> KeyValue:
    return _setup_link(key, KeyValue)

func index_item_mut(key: Variant) -> KeyValueMut:
    return _setup_link(key, KeyValueMut)

func has(key: Variant) -> bool:
    return key in _inner.value

class PropObserver:
    extends ObservableMut

    var _obj: RefCounted
    var _prop: String

    func _init(obj, prop: String) -> void:
        self._obj = obj
        self._prop = prop

    func get_value() -> Variant:
        return self._observable.get(self._prop)

    func set_value(val: Variant) -> void:
        self._obj.set(self._prop, val)
        emit_change()


func _setup_link(key: Variant, type):
    if !(key in self._inner):
        return null
    
    if key in self._obs:
        return self._obs[key]
    
    var kv = type.new()
    kv.v = PropObserver.new(self._inner, key)
    kv.v.changed.connect(self._update.bind(key))
    kv.k = ObservableValue.new(key)
    
    _obs[key] = kv
    
    return kv

func _update(key):
    emit_item_change(Tracked.MODIFIED, key)
