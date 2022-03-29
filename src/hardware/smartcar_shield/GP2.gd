class_name GP2
extends HardwareBase

var pin = 0
var min_distance: float = 0.0
var max_distance: float = 4.0

@onready
var _pin: GpioPin = _rec[0]

func requires() -> Array:
    return [{c = gpio_pin(pin), ex=true}]

var _distance: float = 0.0
var distance: float:
    set(dist):
        if dist < min_distance:
            dist = 0.0
        
        _pin.analog_write(int(dist * 10))
    get:
        return _distance
