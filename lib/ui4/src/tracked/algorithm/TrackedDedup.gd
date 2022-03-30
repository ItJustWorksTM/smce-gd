class_name TrackedDedup extends Tracked

var _current
var _observable: Tracked

func _init(observable: Tracked):
    self._current = observable.value()
    self._observable = observable
    
    self._observable.changed.connect(self._on_change)

func value(): return self._current

func change(v):
    if self._current != v:
        self._observable.change(v)

func _on_change(w,h):
    var new = self._observable.value()
    if self._current != new:
        self._current = new
        emit_set()

func _get_class(): return "TrackedDedup"
