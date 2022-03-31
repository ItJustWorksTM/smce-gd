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
    
        c.child(func(c: Ctx):
            c.inherits(Node)
            var state = c.register_state(UserConfigState, UserConfigState.new())
            state.set_default_config.call(Defaults.user_config())
        )
        c.child(WorldEnv.world_env())
        c.child_opt(Cx.use_states([UserConfigState], func(usr): return func(c: Ctx): 
            if !usr: return
            c.inherits(SketchState, [usr])
            c.register_state(SketchState, c.node())
        ))
        c.child_opt(Cx.use_states([SketchState], func(sk): return func(c: Ctx): 
            if !sk: return
            c.inherits(BoardImpl.board_impl(sk))
        ))
        c.child_opt(Cx.use_states([BoardState, SketchState, UserConfigState], func(bd, sk, usr): return func(c: Ctx):
            if !(bd && usr && sk): return
            c.inherits(HardwareImpl.hardware_impl(bd, sk, usr))
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
    ))
    
#    $Cx.add_child(root)
