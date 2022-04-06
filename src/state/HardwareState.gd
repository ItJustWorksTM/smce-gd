class_name HardwareState extends Node

var registered_hardware := TrackedDict.new()
var registered_devices := TrackedDict.new()

func register_hardware(hardware_name, script):
    if registered_hardware.contains(hardware_name):
        printerr("Hardware already exists")
        return false
    
    var devices = script.register()
    
    var mapped_devices = {}
    
    for device in devices:
        if registered_devices.contains(device.device_name):
            printerr("Device already exists")
            return false
    
    for device in devices:
        mapped_devices[device.device_name] = device
    
    registered_hardware.insert_at(hardware_name, { script = script, devices = mapped_devices })

func _ctx_init(c: Ctx):
    c.register_as_state()
