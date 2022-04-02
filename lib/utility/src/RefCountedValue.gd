class_name RefCountedValue

var value

func _init(init = null) -> void:
    self.value = init

func _to_string() -> String:
    return "Ref{ value: %s }" % str(self.value)
