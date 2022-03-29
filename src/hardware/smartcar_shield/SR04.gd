class_name SR04
extends HardwareBase

var echo_pin: int = 0
var trigger_pin: int = 0

var max_angle: float = 1.3
var max_distance: float = 40
var min_distance: float = 0.2
var layers: Array[int] = [16, 4, 1]

@onready
var _echo_pin: GpioPin = _rec[0]
@onready
var _trigger_pin: GpioPin = _rec[1]

func requires() -> Array:
	return [
		{c = gpio_pin(echo_pin), ex=true},
		{c = gpio_pin(trigger_pin), ex=true}
	]

var _distance: float = 0.0
var distance: float:
	set(dist):
		if dist > 0: dist = clamp(dist, min_distance, max_distance)
		_echo_pin.analog_write(int(dist * 10))
	get:
		return _distance

func _to_string():
	return Reflect.stringify_struct("SR04", self, Node)
