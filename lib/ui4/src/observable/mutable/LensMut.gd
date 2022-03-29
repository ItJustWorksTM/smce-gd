class_name LensMut
extends ObservableMut

var _observable: ObservableMut
var _prop: String

func _init(ob: ObservableMut, prop: String) -> void:
    self._observable = ob
    self._prop = prop
    
    ob.changed.connect(self.emit_change)

func get_value() -> Variant:
    return self._observable.value[self._prop]

func set_value(val: Variant) -> void:
    self._observable.value[self._prop] = val
