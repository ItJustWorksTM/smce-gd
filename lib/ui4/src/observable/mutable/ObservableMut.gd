class_name ObservableMut
extends Observable

func __set_value(value: Variant) -> void: set_value(value)

func set_value(value: Variant) -> void: Fn.unreachable()

func mut_scope(cb: Callable) -> void:
    if self.value is Object || self.value is Dictionary:
        cb.call(self.value)
        self.set_value(self.value)
    else:
        self.set_value(cb.call(self.value))

# NOTE TO SELF: all we really is want the type difference so we could just inherit from the non mutable...
