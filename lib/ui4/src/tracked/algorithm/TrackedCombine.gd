class_name TrackedCombine extends TrackedContainer

var _values: Array = []
var _tracked: Array[Tracked]

func value(): return self._values
func size(): return self._values.size()
func keys(): return self._values.size()

func _init(tracked: Array[Tracked]):
    self._tracked = tracked
    _values.resize(tracked.size())
    for i in tracked.size():
        tracked[i].connect("changed", self._on_change, [i])
        self._on_change(0, 0, i)

func _on_change(w: int, h, i):
    self._values[i] = self._tracked[i].value()
    self._emit_change(MODIFIED, i)

func _get_class(): return "TrackedCombine"

func _to_string():
    return "TrackedCombine(%s)" % str(_tracked)
