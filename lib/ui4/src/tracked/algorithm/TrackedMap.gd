class_name TrackedMap extends Tracked

var _observable: Tracked
var _transform: Callable

var _value: Variant

func _init(observable: Tracked, transform: Callable):
    self._observable = observable
    self._transform = transform
    self._observable.changed.connect(self._update)
    _update(SET, 0)

func _update(w,_h):
    self._value = _transform.call(self._observable.value())
    emit_set()

func value() -> Variant:
    return self._value

func _get_class(): return "TrackedMap"
