class_name TrackedTransform extends TrackedContainer

var _values = {}
var _transform: Callable
var _tracked_container: TrackedContainer

func value(): return self._values
func size(): return self._values.size()
func keys(): return self._values.keys()

func _init(tracked_container: TrackedContainer, transform: Callable = func(v): return v):
    self._transform = transform
    self._tracked_container = tracked_container

    tracked_container.connect("changed", self._on_change)
    
    for key in tracked_container.keys():
        _update_item(key)

func _on_change(w: int, h):
    
    match w:
        SET:
            _values.clear()
            for key in self._tracked_container.keys():
                _update_item(key)
            _emit_change(SET, h)
        MODIFIED:
            _update_item(h)
            _emit_change(MODIFIED, h)
        REMOVED:
            self._values.erase(h)
            _emit_change(REMOVED, h)
        INSERTED:
            _update_item(h)
            _emit_change(INSERTED, h)
        MOVED: # TODO: figure out if this is legit?
            _emit_change(MOVED, h)
            self._values.erase(h[0])            
            _update_item(h[1])
            _emit_change(MODIFIED, h[1])
                        

func _update_item(key):
    var val = self._tracked_container.value_at(key)
    var new = self._transform.call(key, val)
    if new is Object && new == Keep: return
    self._values[key] = new

func _get_class(): return "TrackedTransform"
