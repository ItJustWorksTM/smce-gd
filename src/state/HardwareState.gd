class_name HardwareState
extends Node

var hardware := TrackedVec.new()
var register = Ui.value({})

var _sketch_state: BoardState
var _config_state: UserConfigState

func _init(sketch_state: BoardState, config_state: UserConfigState) -> void:
    self._sketch_state = sketch_state
    self._config_state = config_state
    
    self._sketch_state.sketches.item_changed.connect(self._updoot)

    register_hardware("BrushedMotor", BrushedMotor)
    register_hardware("SR04", SR04)
    register_hardware("UartPuller", UartPuller)
    register_hardware("GY50", GY50)

func _updoot(w,h):
    match w:
        TrackedContainer.INSERTED:
            print("inserting..", self.hardware)
            self.hardware.insert(h, {
                id = self._sketch_state.sketches.index_item(h).v.value.id,
                by_label = {}
            })
            print("done!", self.hardware)
            _updoot(TrackedContainer.MODIFIED, h)
        TrackedContainer.MODIFIED:
            _update(self._sketch_state.sketches.index_item(h))
        TrackedContainer.ERASED:
            self.hardware.erase(h)
        TrackedContainer.CLEARED:
            for k in h:
                self.hardware.erase(k)

func _update(vk):
    var v = vk.v.value
    
    var existing = self.hardware.find_item(func(_vk): return _vk.v.value.id == vk.v.value.id)
    assert(existing != null)
    
    match v.board:
        BoardState.BOARD_UNAVAILABLE:
            existing.v.value.by_label = {}
        BoardState.BOARD_RUNNING, BoardState.BOARD_SUSPENDED, BoardState.BOARD_READY:
            return
        BoardState.BOARD_STAGING:
            if self.hardware.has(v.id):
                assert(false, "free....")
            
            var config = self._config_state.get_config_for(v.id)
            
            var hw = config.hardware
            
            var ret = {}
            for key in hw.keys():
                var label = key
                var props: Dictionary = hw[key].duplicate()
                var type = props.type
                
                props.erase("type")
                
                if type in register.value:
                    var object = register.value[type].new()
                    
                    for prop in props.keys():
                        object.set(prop, props[prop])
                    
                    _sketch_state.request_hardware(v.id, object)
                    
                    ret[key] = object
                else:
                    assert(false, "nooo")
            
            existing.v.value.by_label = ret
            pass
        _: assert(false)

func register_hardware(hardware_name, script) -> void:
    register.value[hardware_name] = script

func populate(skt: Callable):
    
    
    pass

