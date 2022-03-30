class_name TrackedCombine extends TrackedContainer

var _values: Array = []
var _observables: Array[Tracked]

func value(): return self._values
func size(): return self._values.size()
func keys(): return self._values.size()

func _init(observables: Array[Tracked]):
    self._observables = observables
    _values.resize(observables.size())
    for i in observables.size():
        observables[i].connect("changed", self._on_change, [i])
        self._on_change(0, 0, i)

func _on_change(w: int, h, i):
    self._values[i] = self._observables[i].value()
    self._emit_change(MODIFIED, i)

func _get_class(): return "TrackedCombine"

func _to_string():
    return "TrackedCombine(%s)" % str(_observables)
