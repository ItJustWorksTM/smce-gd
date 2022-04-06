class_name AttachmentState extends Node

var attachments := TrackedDict.new()

var wenv: Tracked

func register_attachment(attachment_name, fn):
    self.attachments.insert_at(attachment_name, fn)

var bd: BoardState; var conf: UserConfigState; var veh: VehicleState;
func _init(bd: BoardState, conf: UserConfigState, veh: VehicleState, wenv: Tracked):
    self.bd = bd; self.conf = conf; self.veh = veh; self.wenv = wenv

func _ctx_init(c: Ctx):
    c.register_as_state()
    
    var w_node = Cx.inner(Cx.map(wenv, func(v): if v: return v.world_node))
        
    c.child_opt(Cx.map_children(bd.boards, func(i, v): return func(c: Ctx):
        c.inherits(Node3D)
        c.with("name", "vehicles")
        var state_buffer = Cx.buffer(Cx.lens(v.board, "state"), 2)
        c.child_opt(Cx.map_child(state_buffer, func(st): match st:
            [BoardState.BOARD_UNAVAILABLE, BoardState.BOARD_RUNNING]: 
                return func(c: Ctx):
                    var z = conf.get_config_for.call(v.info.value().source, "vehicle")
                    var vehicle_name = z.name
                    var veh_attachments = z.attachments
                    var voop = {}
                    for att in veh_attachments.keys():
                        var val = veh_attachments[att]
                        var at_fn = attachments.value_at(val.type)
                        var map_hard = {}
                        for hardwareee in val.hardware.keys():
                            map_hard[hardwareee] = v.board.value().hardware[val.hardware[hardwareee]]
                        for prop in val.get("props", []):
                            map_hard[prop] = val.props[prop]
                        voop[att] = at_fn.call(map_hard)
                    
                    var vehicle_fn = veh.registered_vehicles.value_at(vehicle_name)
                    var vehoo = vehicle_fn.call(voop)
                    var spawn := Transform3D()
                    spawn.origin = Vector3(0,10,0)
                    
                    var world = w_node.value()
                    if world && world.has_method("get_spawnpoint"):
                        spawn = world.get_spawnpoint("vehicle")
                    
                    c.inherits(vehoo)
                    c.with("transform", spawn)
            [_, BoardState.BOARD_UNAVAILABLE]:
                return func(c: Ctx): pass
            _: return Tracked.Keep
        ))
    ))
