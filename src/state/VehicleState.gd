class_name VehicleState extends Object

var registered_vehicles := TrackedDict.new()

var active_vehicles := TrackedDict.new()

var register_vehicle = func(vehicle_name: String, node_fn: Callable): pass
var unregister_vehicle = func(vehicle_name: String): pass

var spawn_vehicle = func(vehicle_name: String, attachments: Dictionary): pass
var despawn_vehicle = func(vehicle_node): pass
var reset_vehicle_position = func(vehicle_node): pass
var freeze_vehicle = func(vehicle_node): pass

static func basic_vehicle(scene, slot_map): return func(attachments): 
    var scene_instance = load(scene)
    return func(c: Ctx):
        c.inherits(scene_instance)
        
        for key in attachments.keys():
            if key in slot_map:
                c.child_at(slot_map[key], attachments[key].call(c.node()))
