class_name Odometer
extends HardwareBase

var pulse_pin: int = 35
var forward_pin: int = 36
var directionless: bool = false

static func smartcar_odometer() -> BoardDeviceSpecification:
	var ret := BoardDeviceSpecification.new()
	ret.name = "SmartcarOdometer"
	ret.version = "1.0"
	ret.fields = {
		total_distance = BoardDeviceSpecification.af64,
		speed = BoardDeviceSpecification.af64,
		directionless = BoardDeviceSpecification.au8,
		direction = BoardDeviceSpecification.as8
	}
	return ret

@onready
var _device = _rec[0]

func requires() -> Array:
	return [
		{c = board_device("SmartcarOdometer", "1.0"), ex=true},
		{c = gpio_pin(pulse_pin), ex=false},
		{c = gpio_pin(forward_pin), ex=false},
	]

var _forward: bool = false
var forward: bool:
	get: return _forward

var _speed: float = 0.0
var speed: float:
	get: return _speed

var _total_distance: float = 0.0
var total_distance: float:
	get: return _total_distance

func increment_distance(amount: float) -> void:
	_device.total_distance += amount
	_total_distance = _device.total_distance

func _process(_delta: float) -> void:
	_device.speed = speed * 1000
	_device.direction = 1 if forward else -1
	
	_total_distance = _device.total_distance



