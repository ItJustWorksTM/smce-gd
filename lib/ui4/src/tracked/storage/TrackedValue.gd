class_name TrackedValue extends Tracked

var __value
var _value:
    set(v): 
        _set_value(v)
    get: 
        return _get_value()

func _set_value(v):
    self.__value = v
    emit_set()    

func _get_value(): return __value

func _init(value: Variant):
    self._value = value

func value(): return self._value

func change(v):
#    assert(typeof(v) == self.type() || v == null, "type mismatch")
    self._value = v

func _get_class(): return "TrackedValue"
