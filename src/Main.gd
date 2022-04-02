class_name Main
extends Node

func _ready():
#    var visualizers = {
#        GY50: func(gy: GY50): return func(c: Ctx): c.inherits(Widgets.label(Cx.poll(gy, "rotation")))
#    }

    $Ui.add_child(CtxExt.create(func(c: Ctx):
        c.inherits(MarginContainer)
    
        var version := Cx.value_dedup("???")
        c.on(version.changed, func(w,h): DisplayServer.window_set_title("SMCE-gd %s" % version.value()))
        version.change("2.0.0-dev")
    
        c.child(UserConfigImpl.user_config_impl())
        c.child(WorldEnvImpl.world_env_impl())
        
        c.child_opt(Cx.use_states([UserConfigState], func(usr): return func(c: Ctx): 
            if !usr: return
            c.inherits(SketchImpl.sketch_impl(usr))
        ))
        
        var conf = c.get_state(UserConfigState).value()
        conf.set_default_config.call(Defaults.user_config())
        
        c.child_opt(Cx.use_states([SketchState], func(sk): return func(c: Ctx): 
            if !sk: return
            c.inherits(BoardImpl.board_impl(sk))
        ))
        c.child_opt(Cx.use_states([BoardState, SketchState, UserConfigState], func(bd, sk, usr): return func(c: Ctx):
            if !(bd && usr && sk): return
            c.inherits(HardwareImpl.hardware_impl(bd, sk, usr))
        ))
        c.child(func(c: Ctx):
            c.inherits(VehicleImpl.vehicle_impl(c.get_state(WorldEnvState)))
        )
        c.child_opt(Cx.use_states([UserConfigState, VehicleState, HardwareState], func(usr, veh, hw): return func(c: Ctx):
            if !(usr && veh && usr): return
            c.inherits(AttachmentImpl.attachment_impl(usr, hw, veh))
        ))
        c.child(func(c: Ctx):
            c.inherits(SmceUiRoot.smce_ui_root())
        )
        
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
        
        env.change_world.call("playground/Playground")
        
        var hw = c.get_state(HardwareState).value()
        
        hw.register_hardware.call("BrushedMotor", BrushedMotor)
        hw.register_hardware.call("SR04", SR04)
        hw.register_hardware.call("UartPuller", UartPuller)
        hw.register_hardware.call("GY50", GY50)
        
        var veh: VehicleState = c.get_state(VehicleState).value() 
        
        var totally_a_vehicle = VehicleState.basic_vehicle(
            "res://assets/models/smartcar/smartcar-rigid.tscn",
            {
                front_top =  "CollisionShape3D",
                front_left = "Slots/FrontLeft",
                front_right = "Slots/FrontRight",
                mid_left = "Wheels/Mid"
            }
        )
        
        veh.register_vehicle.call("smartcar", totally_a_vehicle)
        
        var ez = {
            front_top = func(vehicle): return func(c: Ctx):
                c.inherits(Node3D)
                c.with("name", "very cool attachment")
                vehicle.apply_impulse(Vector3(randf_range(0.0,10.0), randf_range(0.0,60.0), randf_range(0,10.0)), Vector3(0,0,0))
        }
        
        for i in 50:
            veh.spawn_vehicle.call("smartcar", ez)

    ))
    
#    $Cx.add_child(root)
