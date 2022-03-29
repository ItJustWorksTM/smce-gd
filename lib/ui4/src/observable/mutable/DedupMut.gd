class_name DedupMut
extends ObservableMut

var _observable: Observable
var _old: Variant

func _init(observable: Observable):
    self._observable = observable
    self._observable.changed.connect(emit_change)

func emit_change():
    var val = self.value
    if self._old != val:
        self._old = val
        super.emit_change()

func get_value() -> Variant:
    return self._observable.value

func set_value(v: Variant) -> void:
    if self.value != v:
        self._observable.set_value(v)
