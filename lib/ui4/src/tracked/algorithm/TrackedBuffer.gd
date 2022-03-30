class_name TrackedBuffer extends TrackedArrayBase

var _observable: Tracked
var _buffer_size: int

func _init(observable: Tracked, buffer_size: int = 1):
    self._buffer_size = buffer_size
    _insert_at(0, observable.value())
    self._observable = observable
    self._observable.connect("changed", self._on_change)

func _on_change(w: int, _h):
    _insert_at(size(), _observable.value())
    if self.size() > _buffer_size:
        _remove_at(0)

func _get_class(): return "TrackedBuffer"
