class_name HardwareImpl
extends Node

static func hardware_impl(
        board_state: BoardState, 
        sketch_state: SketchState,
        config_state: UserConfigState
    ): return func(c: Ctx):
    
    c.inherits(Node)
    
    var state = c.register_state(HardwareState, HardwareState.new())
       
    state.hardware = Cx.transform(board_state.boards, func(v, keep):
        match v.state:
            BoardState.BOARD_UNAVAILABLE:
                return { by_label = {} }
            BoardState.BOARD_RUNNING, BoardState.BOARD_SUSPENDED:
                return keep.keep()
            BoardState.BOARD_STAGING:
                # TODO: find a way to not depend on the sketch path?
                var sk = sketch_state.sketches.value_at(v.attached_sketch.value())
                var config = config_state.get_config_for.call(
                    sk.sketch.source, 
                    "hardware"
                )
                
                var hw = config
                
                var ret = {}
                for key in hw.keys():
                    var label = key
                    var props: Dictionary = hw[key].duplicate()
                    var type = props.type
                    
                    props.erase("type")
                    
                    if type in state.register.value():
                        var object = state.register.value()[type].new()
                        
                        for prop in props.keys():
                            object.set(prop, props[prop])
                        
                        v.request_fn.call(object)
                        
                        ret[key] = object
                    else:
                        assert(false, "nooo")
                
                return { by_label = ret }
    )
    
    state.register_hardware = func(hardware_name, script):
        state.register.mutate(func(v):
            v[hardware_name] = script
            return v
        )
