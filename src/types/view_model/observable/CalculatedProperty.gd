
class_name CalculatedProperty
extends ManyObserver

var _result

var _obj
var _method

func get_value():
    return _result

func _init(obj, method, obsvrs).(obsvrs):
    _obj = obj
    _method = method
    _update_result()

func _update_result():
    _result = _obj.callv(_method, _values)

func _on_change(new_value, i):
    _values[i] = new_value
    _update_result()
    emit_change()

