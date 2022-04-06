class_name Main
extends Node

func _ready():
    $Ui.add_child(CtxExt.create(func(c: Ctx):
        c.inherits(MarginContainer)
    
        var version := Cx.value_dedup("???")
        c.on(version.changed, func(w,h): DisplayServer.window_set_title("SMCE-gd %s" % version.value()))
        version.change("2.0.0-dev")
    
        c.child(UserConfigState)
        var conf = c.get_state(UserConfigState).value() as UserConfigState
        conf.set_default_config.call(Defaults.user_config())

        c.child(WorldEnvState)
        var env = c.get_state(WorldEnvState).value()
        
        var playground = load("res://assets/scenes/environments/playground/Playground.tscn")
        env.register_world.call("playground/Playground",
            func(c: Ctx):
                var scene: PackedScene = playground
                c.inherits(scene)
        )
        
        var test_lab = load("res://assets/scenes/environments/test_lab/TestLab.tscn")
        env.register_world.call("test_lab/TestLab",
            func(c: Ctx):
                var scene: PackedScene = test_lab
                c.inherits(scene)
        )
        
        env.change_world.call("test_lab/TestLab")
        
        c.child(HardwareState)
        var hw = c.get_state(HardwareState).value()
        
        hw.register_hardware.call("BrushedMotor", BrushedMotor)
        hw.register_hardware.call("SR04", SR04)
        hw.register_hardware.call("UartPuller", UartPuller)
        hw.register_hardware.call("GY50", GY50)

        c.child(VehicleState)
        var veh: VehicleState = c.get_state(VehicleState).value() 
        var smartcar_shield = VehicleState.basic_vehicle(
            "res://assets/scenes/objects/vehicles/SmartcarShield.tscn",
            {
                right =  "attachment_slots/right",
                right_motor = "attachment_slots/front_top",
                left =  "attachment_slots/left",
                left_motor = "attachment_slots/front_top",
                back =  "attachment_slots/back",
                front =  "attachment_slots/front",
                front2 = "attachment_slots/front2",
                internal = "attachment_slots/front_top",
            }
        )
        
        veh.register_vehicle.call("smartcar_shield", smartcar_shield)
        
        c.child_opt(Cx.use_states([UserConfigState, HardwareState], func(usr, hw): return func(c: Ctx): 
            if (usr && hw): c.inherits(SketchState, [usr, hw])
        ))
        var sks = c.get_state(SketchState).value()
        sks.add_sketch.call("/home/ruthgerd/Sources/.tracking/smartcar-shield/examples/Car/manualControl")
#        sks.add_sketch.call("/home/ruthgerd/Sources/.tracking/smartcar-shield/examples/sensors/gyroscope/gyroscopeHeading/gyroscopeHeading.ino")
#        sks.add_sketch.call("/home/ruthgerd/Sources/.tracking/smartcar-shield/examples/sensors/infrareds/GP2D120/GP2D120.ino")

        c.child_opt(Cx.use_states([SketchState], func(sk): return func(c: Ctx): 
            if (sk): c.inherits(BoardState, [sk])
        ))
        var bd = c.get_state(BoardState).value()
        bd.add_board.call(0)
        
        c.child_opt(Cx.use_states([BoardState, UserConfigState, VehicleState], func(bd, usr, veh): return func(c: Ctx):
            if (usr && veh && bd): c.inherits(AttachmentState, [bd, usr, veh, c.get_state(WorldEnvState)])
        ))
        var att = c.get_state(AttachmentState).value()
        
        var generic_attachment = func(type): return func(props): return func(vehicle): return func(c: Ctx):
            c.inherits(type)
            c.with("vehicle", vehicle)
            for prop in props.keys():
                c.with(prop, props[prop])
        
        att.register_attachment.call("MotorDriver", generic_attachment.call(MotorDriver))
        att.register_attachment.call("ConeRaycaster", generic_attachment.call(ConeRaycaster))
        
        c.child(func(c: Ctx):
            c.inherits(SmceUiRoot.smce_ui_root())
        )
    ))
