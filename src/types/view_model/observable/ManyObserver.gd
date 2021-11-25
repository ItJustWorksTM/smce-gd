
class_name ManyObserver
extends Observable

var _values = []

func get_value(): return _values
func set_value(__):
    push_error("Can't assign ManyObserver")
    assert(false)

func _init(observables: Array):
    var i = 0
    for obsvr in observables:
        if obsvr is Observable:
            obsvr.connect("changed", self, "_on_change", [i])
            _values.append(obsvr.value)
        else:
            _values.append(obsvr)
        i += 1

func _on_change(new_value, i):
    _values[i] = new_value
    emit_change()
