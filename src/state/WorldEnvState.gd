class_name WorldEnvState extends Node

enum { CAMERA_ORBITING, CAMERA_FREE }

# state
var worlds := Cx.array([])
var current_world := Cx.value(-1)
var current_world_name := Cx.combine_map(
    [worlds as Tracked, current_world],
    func(w, c): return w[c] if c >= 0 else ""
)

var world_node := Cx.value(null)

var camera_following_node := Cx.value(null)
var camera_mode := Cx.map(camera_following_node, func(f): CAMERA_FREE if f == null else CAMERA_ORBITING)

var _world_fns := {}
    
func register_world(world_name, w):
    assert(w != null)
    _world_fns[world_name] = w
    self.worlds.push(world_name)

func change_world(world_name):
    var index = self.worlds.value().find(world_name)
    
    if index >= 0:
        self.current_world.change(index)

func _ctx_init(c: Ctx):
    c.register_as_state()
    
    c.child(func(c: Ctx): 
        c.inherits(FreeCamera)
        c.with("position", Vector3(0,0.3,0))
        c.with("rotation", Vector3(-PI/4,0,0))
    )
    
    c.child_opt(Cx.map_child(self.current_world, func(i): return func(c: Ctx):
        if i < 0:
            world_node.change(null)
            return
        
        var node = _world_fns[worlds.value_at(i)]
        c.inherits(node)
        
        world_node.change(c.node())
    ))
