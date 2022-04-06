class_name GY50
extends HardwareBase

static func register():
    return [ smartcar_gyroscope() ]

static func smartcar_gyroscope() -> BoardDeviceSpecification:
    var ret = BoardDeviceSpecification.new()
    ret.device_name = "SmartcarGyro"
    ret.fields = {
        id = BoardDeviceSpecification.au64,
        rotation = BoardDeviceSpecification.af64,
    }
    return ret

@onready
var _device = _rec[0]

func requires() -> Array:
    return [
        { c = board_device("SmartcarGyro"), ex = true}
    ]

var _rotation: float = 0.0
var rotation: float:
    get: return _device.get("rotation") if _device else 0.0
    set(r): _device.set("rotation", clamp(r, 0.0, 360.0))

#@onready
#var _poll = Polled.new(self, "rotation")
#
#func _ready():
#    _poll.changed.connect(func(): print("rotation: ", _poll.value))

func _to_string():
    return Reflect.stringify_struct("GY50", self, Node)
