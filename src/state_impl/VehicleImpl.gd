class_name VehicleImpl

# TODO: why is this not just pure lol? we just need a central place to put vehicles?

static func vehicle_impl(world_env: Tracked): return func(c: Ctx):
    c.inherits(Node)
    c.with("name", "VehicleImpl")
    
    var state: VehicleState = c.register_state(VehicleState, VehicleState.new())
    
    state.register_vehicle = func(vehicle_name: String, node_fn: Callable):
        if state.registered_vehicles.contains(vehicle_name):
            printerr("VehicleState: unregister a vehicle before registering it again")
        
        state.registered_vehicles.insert_at(vehicle_name, node_fn)
    
    state.unregister_vehicle = func(vehicle_name: String):
        printerr("TODO")

    var vehicle_id = RefCountedValue.new(0)

    var w_node = Cx.inner(Cx.map(world_env, func(v): if v: return v.world_node))

    state.spawn_vehicle = func(vehicle_name: String, attachments: Dictionary):
        var vehicle_fn = state.registered_vehicles.value_at(vehicle_name)
        
        var veh = vehicle_fn.call(attachments)
        vehicle_id.value += 1
        
        var spawn := Transform3D()
        spawn.origin = Vector3(0,10,0)
        
        var world = w_node.value()
        if world && world.has_method("get_spawnpoint"):
            spawn = world.get_spawnpoint("vehicle")

        var vehicle_ctx = c.child(func(c: Ctx):
            c.inherits(veh)
            c.with("transform", spawn)
        )
        
        state.active_vehicles.insert_at(vehicle_id.value, vehicle_ctx.node())
        
        return vehicle_id.value
    
    state.despawn_vehicle = func(vehicle_id):
        var node = state.active_vehicles.value_at(vehicle_id)
        c.node().remove_child(node)
        node.queue_free()
    
    state.reset_vehicle_position = func(vehicle_node):
        printerr("TODO")
