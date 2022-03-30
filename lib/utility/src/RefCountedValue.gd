class_name RefCountedValue

var value

func _to_string():
    return "Ref{ value: %s }" % str(self.value)
