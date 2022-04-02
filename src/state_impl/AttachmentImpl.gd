class_name AttachmentImpl extends Node



# for future reference: dont need board at all, just need to spawn what hardware gives us :)
# you lied, there may also be no hardware :)
static func attachment_impl(conf: UserConfigState, hw: HardwareState, veh: VehicleState, bd: BoardState): return func(c: Ctx):
    c.inherits(Node)
    
    var state = c.register_state(AttachmentState, AttachmentState.new())
    
    

