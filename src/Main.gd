class_name Main
extends Node

#
#static func line_edit(value: Observable): return func(c: Ctx):
#    var this = c.inherits(LineEdit).object() as LineEdit
#    var input = c.user_signal("input")
#
#    c.on("text_changed", func(t): input.emit(t))
#    c.use(value, func(v):
#        this.text = v
#        this.caret_column = v.length()
#    )
#

func _ready():
    
    var version := Track.value_dedup("???")
    version.changed.connect(func(w,h): DisplayServer.window_set_title("SMCE-gd %s" % version.value))
    version.change("2.0.0-dev")

#	var resource_directory := Ui.dedup_value("")
#	resource_directory.changed.connect(func():
#		print("TODO: copy RtResources into resource directory")
#	)
#	resource_directory.value = OS.get_user_data_dir()
#
#	var board_config := BoardConfig.new()
#	board_config.uart_channels += [UartChannelConfig.new()]
#	board_config.gpio_drivers += [GpioPin.new()]
#	board_config.pins = [0]
#
#	var default_board_config := Ui.value(board_config)
#
#	var sketch_config := SketchConfig.new()
#	sketch_config.legacy_preproc_libs = ["MQTT@2.5.0", "WiFi@1.2.7", "Arduino_OV767X@0.0.2", "SD@1.2.4"]
#
    
    var visualizers = {
        GY50: func(gy: GY50): return func(c: Ctx): c.inherits(Widgets.label(Track.poll(gy, "rotation")))
    }

    var root = CtxExt.create(func(c: Ctx):
        c.inherits(MarginContainer)
        c.child(func(c: Ctx):
            c.inherits(UserConfigState)
            c.node().set_default_config(Defaults.user_config())
            c.register_state(UserConfigState, c.node())
        )
        c.child(func(c: Ctx): 
            c.inherits(SketchState, [c.use_state(UserConfigState)])
            c.register_state(SketchState, c.node())
        )
        c.child(func(c: Ctx): 
            c.inherits(BoardState, [c.use_state(SketchState)])
            c.register_state(BoardState, c.node())
        )
        c.child(func(c: Ctx):
            c.inherits(HardwareState, [c.use_state(BoardState), c.use_state(UserConfigState)])
            c.register_state(HardwareState, c.node())
        )
        c.child(func(c: Ctx): 
            c.inherits(WorldEnvState)
            c.register_state(WorldEnvState, c.node())
            var sketch_state: BoardState = c.use_state(BoardState)
            var hardware_state: HardwareState = c.use_state(HardwareState)
            var world_state: WorldEnvState = c.node()
            
            print(hardware_state.hardware.size())
        )
        c.child(func(c: Ctx):
            c.inherits(SmceUiRoot.smce_ui_root())
        )
        c.child(func(c: Ctx):
            c.inherits(Node)
            var print_change = func(prefix, v):
                v.changed.connect(func(_w, _h): print(prefix,": ", v))
                print(prefix,": ",  v)
                
            print_change.call("Boards", c.use_state(BoardState).boards)
            print_change.call("Sketches", c.use_state(SketchState).sketches) 
            var hw = c.use_state(HardwareState)
            print_change.call("Hardware", hw.hardware)
            print_change.call("Registry", hw.register)
            
            print(Reflect.stringify_struct("WorldEnvState", c.use_state(WorldEnvState), Node3D))
            
            pass
        )
    )
    
    $Ui.add_child(root)
