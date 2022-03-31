class_name WorldEnv
extends Node3D


static func world_env(): return func(c: Ctx):
    c.inherits(Node3D)
    
    var state: WorldEnvState = c.register_state(WorldEnvState, WorldEnvState.new())
    
    var world_fns := {}
    
    state.register_world = func(world_name, w):
        assert(w != null)
        world_fns[world_name] = w
        state.worlds.push(world_name)
    
    state.change_world = func(world_name):
        var index = state.worlds.value().find(world_name)
        
        if index >= 0:
            state.current_world.change(index)
    
    c.child_opt(Cx.map_child(state.current_world, func(i): return func(c: Ctx):
        if i < 0: return
        var node = world_fns[state.worlds.value_at(i)]
        c.inherits(node)
    ))
    
    c.child(func(c: Ctx): c.inherits(FreeCamera))
