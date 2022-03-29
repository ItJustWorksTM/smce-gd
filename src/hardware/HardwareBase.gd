class_name HardwareBase
extends Node

var _rec

func requires() -> Array:
    return []

static func gpio_pin(pin: int, read: bool = true, write: bool = true) -> GpioDriverConfig:
    var ret := GpioDriverConfig.new()
    ret.pin = pin
    ret.read = read
    ret.write = read
    return ret

static func uartchannel() -> UartChannelConfig:
    return UartChannelConfig.new()

static func framebuffer(key: int) -> FrameBufferConfig:
    var ret := FrameBufferConfig.new()
    ret.key = key
    return ret

static func board_device(device_name: String) -> BoardDeviceConfig:
    var ret := BoardDeviceConfig.new()
    ret.device_name = device_name
    ret.count = 1
    return ret

static func digital_storage(path: String, cspin: int) -> SecureDigitalStorageConfig:
    var ret := SecureDigitalStorageConfig.new()
    ret.root_dir = path
    ret.cspin = cspin
    
    return ret
