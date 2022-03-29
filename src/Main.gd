extends Node
class_name Main

func _ready():
    var version := Ui.dedup_value("???")
    version.changed.connect(func(): DisplayServer.window_set_title("SMCE-gd %s" % version.value))
    version.value = "2.0.0-dev"

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
        GY50: func(gy: GY50): return func(ctx: Ctx): 
            ctx \
                .inherits(Widgets.label(Ui.poll(gy, "rotation")))
    }

    var root = Ui.make_ui_root(func(ctx: Ctx): ctx \
        .inherits(MarginContainer) \
        .child(func(ctx): 
            ctx.inherits(BoardState)
            ctx.register_state(BoardState, ctx.object()) \
        ) \
        .child(func(ctx):
            ctx.inherits(UserConfigState)
            ctx.object().set_default_config(Defaults.user_config())
            ctx.register_state(UserConfigState, ctx.object()) \
        ) \
        .child(func(ctx):
            ctx.inherits(HardwareState, [ctx.use_state(BoardState), ctx.use_state(UserConfigState)])
            ctx.register_state(HardwareState, ctx.object()) \
        ) \
        .child(func(ctx): 
            ctx.inherits(WorldEnvState)
            ctx.register_state(WorldEnvState, ctx.object())
            var sketch_state: BoardState = ctx.use_state(BoardState)
            var hardware_state: HardwareState = ctx.use_state(HardwareState)
            var world_state: WorldEnvState = ctx.object()
            
            print(hardware_state.hardware.size())
#			var gui_uart = TrackedMapped.new(hardware_state.hardware, func(vk):
#				var ret = vk.by_label.get("Gui Uart")
#				if ret != null:
#					print("something not null!")
#				return ret
#			)
#
#
#			gui_uart.changed.connect(func():
#				print("gui_uart changed: ", gui_uart)
#				gui_uart.for_each_item(func(vk):
#					if vk.v.value != null:
#						pass
#				)
#			)
            
            pass \
        ) \
        .child(func(ctx): ctx \
            .inherits(SmceUiRoot.smce_ui_root()) \
        ) \
    )
    
    $Ui.add_child(root)
