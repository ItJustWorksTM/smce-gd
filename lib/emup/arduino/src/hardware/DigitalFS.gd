class_name DigitalFS
extends HardwareBase

var path = ""
var cspin = 0

@onready
var _store = _rec[0]

func requires() -> Array:
    return [
        { c = digital_storage(path, cspin)}
    ]
