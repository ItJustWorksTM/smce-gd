class_name BrushedMotor
extends HardwareBase

var fwd_pin: int = 35
var bwd_pin: int = 35
var enable_pin: int = 35

@onready
var _fwd_pin: GpioPin = _rec[0]
var _bwd_pin: GpioPin = _rec[1]
var _enable_pin: GpioPin = _rec[2]

func requires() -> Array:
	return [
		{c = gpio_pin(fwd_pin), ex=true},
		{c = gpio_pin(bwd_pin), ex=true},
		{c = gpio_pin(enable_pin), ex=true},
	]

var _speed: float = 0.0
var speed: float:
	get: return _speed

func _process(_delta: float) -> void:
	var abs_speed := _enable_pin.analog_read()
	var direction := int(_fwd_pin.digital_read()) - int(_bwd_pin.digital_read())
	
	_speed = (abs_speed / 255.0) * direction
