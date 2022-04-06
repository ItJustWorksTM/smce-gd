class_name VehicleState extends Node

var registered_vehicles := TrackedDict.new()

func register_vehicle(vehicle_name: String, node_fn: Callable):
    if self.registered_vehicles.contains(vehicle_name):
        printerr("VehicleState: unregister a vehicle before registering it again")
    
    self.registered_vehicles.insert_at(vehicle_name, node_fn)

func unregister_vehicle(vehicle_name: String):
    printerr("TODO")

func _ctx_init(c: Ctx):
    c.register_as_state()

static func basic_vehicle(scene, slot_map): return func(attachments): 
    var scene_instance = load(scene)
    return func(c: Ctx):
        c.inherits(scene_instance)
        
        for key in attachments.keys():
            if key in slot_map:
                c.child_at(slot_map[key], attachments[key].call(c.node()))
