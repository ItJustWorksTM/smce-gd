class_name GY50
extends HardwareBase

static func smartcar_gyroscope() -> BoardDeviceSpecification:
	var ret = BoardDeviceSpecification.new()
	ret.name = "SmartcarGyro"
	ret.version = "1.0"
	ret.fields = {
		rotation = BoardDeviceSpecification.f64
	}
	return ret

@onready
var _device = _rec[0]

func requires() -> Array:
	return [
		{ c = board_device("SmartcarGyro", "1.0"), ex = true}
	]

var _rotation: float = 0.0
var rotation: float:
	get: return _rotation
	set(r): _device.rotation = clamp(r, 0, 360)
