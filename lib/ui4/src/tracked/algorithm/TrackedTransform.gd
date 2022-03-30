class_name TrackedTransform extends TrackedContainer

var _values: Array = []
var _transform: Callable
var _tracked_arr: TrackedArrayBase

func value(): return self._values
func size(): return self._values.size()
func keys(): return self._values.size()

func _init(tracked_arr: TrackedArrayBase, transform: Callable = func(v): return v):
    self._transform = transform
    self._tracked_arr = tracked_arr
    _values.resize(tracked_arr.size())
    tracked_arr.connect("changed", self._on_change, [tracked_arr])
    
    for key in tracked_arr.keys():
        _update_item(key)

func _on_change(w: int, h, ob: TrackedArrayBase):
    
    match w:
        SET:
            _values.clear()
            _values.resize(_tracked_arr.size())
            for key in _tracked_arr.keys():
                _update_item(key)
            _emit_change(SET, 0)
        MODIFIED:
            _update_item(h)
            _emit_change(MODIFIED, h)
        REMOVED:
            self._values.remove_at(h)
        INSERTED:
            self._values.insert(h, null)
            _update_item(h)
            _emit_change(INSERTED, h)
        MOVED:
            _emit_change(MOVED, h)

class Keep:
    var _kept: = false
    func keep(): self._kept = true

var _keep = Keep.new()
func _update_item(key):
    _keep._kept = false
    var new = self._transform.call(self._tracked_arr.value_at(key), _keep)
    if !_keep._kept:
        self._values[key] = new

func _get_class(): return "TrackedTransform"
