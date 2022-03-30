class_name HardwareState
extends Node

var hardware: TrackedContainer
var register := Track.value({})

var _board_state: BoardState
var _config_state: UserConfigState

func _init(board_state: BoardState, config_state: UserConfigState) -> void:
    self._board_state = board_state
    self._config_state = config_state
    
    hardware = Track.transform(self._board_state.boards, func(v, keep):
        print(v)
        print(BoardState.BOARD_UNAVAILABLE)
        match v.state:
            BoardState.BOARD_UNAVAILABLE:
                return { by_label = {} }
            BoardState.BOARD_RUNNING, BoardState.BOARD_SUSPENDED:
                return keep.keep()
            BoardState.BOARD_STAGING:
                var sk = board_state._sketch_state.sketches.value_at(v.attached_sketch.value())
                var config = config_state.get_config_for(
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
                    
                    if type in register.value():
                        var object = register.value()[type].new()
                        
                        for prop in props.keys():
                            object.set(prop, props[prop])
                        
                        # TODO: FUCK YOU
                        var vid = _board_state.boards.value().find(v)
                        _board_state.request_hardware(vid, object)
                        
                        ret[key] = object
                    else:
                        assert(false, "nooo")
                
                return { by_label = ret }
    )

    register_hardware("BrushedMotor", BrushedMotor)
    register_hardware("SR04", SR04)
    register_hardware("UartPuller", UartPuller)
    register_hardware("GY50", GY50)


func register_hardware(hardware_name, script) -> void:
    register.mutate(func(v):
        v[hardware_name] = script
        return v
    )

func populate(skt: Callable):
    
    
    pass

