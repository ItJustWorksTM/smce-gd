class_name TrackedPoll extends Tracked

var _value = null
var _value_fn

func value(): return _value

func _init(value_fn: Callable):
    self._value_fn = value_fn

    Engine.get_main_loop().process_frame.connect(self.poll)
    poll()

func poll():
    var new_value = self._value_fn.call()
    
    if !(new_value is Object && new_value == Keep):
        _value = new_value
        emit_set()
