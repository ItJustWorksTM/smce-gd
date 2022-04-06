class_name TrackedBuffer extends TrackedValue

var _observable: Tracked
var _buffer_size: int

func _init(observable: Tracked, buffer_size: int = 1):
    self._buffer_size = buffer_size
    
    var buffer = []
    buffer.resize(buffer_size)
    _value = buffer
    
    self._observable = observable
    self._observable.connect("changed", self._on_change)
    
    _on_change(0,0)

func _on_change(w: int, _h):
    var now = _value
    
    now.push_back(_observable.value())
    
    if now.size() > _buffer_size:
        now.pop_front()
    
    _value = now

func _get_class(): return "TrackedBuffer"
