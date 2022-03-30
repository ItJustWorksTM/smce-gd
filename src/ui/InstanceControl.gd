class_name InstanceControl
extends Control

static func instance_control(board: Tracked) -> Callable: return func(c: Ctx):
    
    var active_attachment = Track.value(-1)
    var log_window_open = Track.value(false)
    
    # TODO: make real..
#
#    var hardware_state: HardwareState = c.use_state(HardwareState)
#
#    var uart_puller = Ui.combine_map([hardware_state.hardware, board_id], func(hardware, id):
#        var board_hardware = hardware.find_item(func(vk): return vk.v.value.id == id)
#        if board_hardware != null:
#            return board_hardware.v.value.by_label.get("Gui Uart")
#    )
#
#    var uart_in = Ui.inner(Ui.map(uart_puller, func(hw):
#        var ret = Ui.value("")
#        if hw: Fn.connect_lifetime(hw, hw.read, func(txt): ret.value += txt)
#        return ret
#    ))
#
#
#    var serial_window_open = Ui.value(false)
    
    var _sketch_state: SketchState = c.use_state(SketchState)
    
    var sketch_id = Track.inner(Track.lens(board, "attached_sketch"))
    var sketch_state = Track.map(sketch_id, func(id):
        if id >= 0:
            return _sketch_state.sketches.value_at(id)
    )
    var board_state = Track.lens(board, "state")
    
    var board_available = Track.map(board_state, func(state): return state != BoardState.BOARD_UNAVAILABLE)
    var board_active = Track.map(board_state, func(state): return state == BoardState.BOARD_RUNNING || state == BoardState.BOARD_SUSPENDED)
    
#    var vehicle_available = Track.map(vehicle_state, func(state): return true)

#    var has_attachments = Track.dedup(Track.map(attachments, func(vec): return !vec.is_empty()))
    var build_state: Tracked = Track.lens(sketch_state, "build_state")
    var build_log: Tracked = Track.lens(sketch_state, "build_log")
    
    var is_building: Tracked = Track.map(build_state, func(state): return state == SketchState.BUILD_PENDING)
#    var has_build_log = Track.map(build_log, func(log): return !log.is_empty())
    
    var sketch_path: Tracked = Track.map(sketch_state, func(s): return s.sketch.source)
    
    var has_build_log: Tracked = Track.map(build_log, func(s): return !s.is_empty())
    
    c.inherits(VBoxContainer)
    
    var remove_self := c.user_signal("remove_pressed")
    var compile_sketch := c.user_signal("compile_sketch")
    var toggle_orbit := c.user_signal("toggle_orbit")
    var toggle_suspend := c.user_signal("toggle_suspend")
    var toggle_board := c.user_signal("toggle_board")
    var reset_vehicle := c.user_signal("reset_vehicle")
    
    var sketch_file = Track.map(sketch_state, func(p): return p.sketch.source.get_file())
    
    c.child(func(c: Ctx):
        c.inherits(Widgets.button())
        c.with("text", sketch_file)
    )
    c.child(func(c: Ctx):
        c.inherits(VBoxContainer)
        c.child(func(c: Ctx):
            c.inherits(Label)
            c.with("text", "Board Control")
        )
        c.child(func(c: Ctx):
            c.inherits(HBoxContainer)
            c.child(func(c: Ctx):
                c.inherits(Widgets.button())
                c.with("text", Track.combine_map([build_state as Tracked, board_state as Tracked], func(sk, bd):
                    match [sk, bd]:
                        [_, BoardState.BOARD_RUNNING]: return "Stop"
                        _: return "Start"
                ))
                c.with("disabled", Track.map(build_state, func(v): return v != SketchState.BUILD_SUCCEEDED))
                c.with("size_flags_horizontal", SIZE_EXPAND_FILL)
                c.with("theme_type_variation", Track.map(board_active, func(v): return "ButtonWarn" if v else "ButtonPrimary"))
                c.on("pressed", func(): toggle_board.emit())
            )
            c.child(func(c: Ctx):
                c.inherits(Widgets.button())
                c.with("text", Track.map(board_state, func(state):
                    match state:
                        BoardState.BOARD_SUSPENDED: return "Resume"
                        _: return "Suspend"
                ))
                c.with("disabled", Track.map(board_active, func(v): return !v))
                c.with("size_flags_horizontal", SIZE_EXPAND_FILL)
                c.on("pressed", func(): toggle_suspend.emit())
            )
        )
    )
    c.child(func(c: Ctx):
        c.inherits(VBoxContainer)
        c.child(func(c: Ctx):
            c.inherits(Label)
#            c.with("text", Track.map(vehicle_state, func(state): return "Vehicle Control" + (" (Frozen)" if state == WorldEnvState.VEHICLE_FROZEN else "")))
        )
        c.child(func(c: Ctx):
            c.inherits(HBoxContainer)
            c.child(func(c: Ctx):
                c.inherits(Widgets.button())
                c.with("text", "Reset Position")
                c.with("size_flags_horizontal", SIZE_EXPAND_FILL)
#                c.with("disabled", Track.map(vehicle_available, func(v): return !v))
                c.on("pressed", func(): reset_vehicle.emit())
            )
            c.child(func(c: Ctx):
#                var is_orbitting = Track.map(camera_state, func(state): return state == WorldEnvState.CAMERA_ORBITING)
                c.inherits(Widgets.button())
                c.with("toggle_mode", true)
                c.with("text", "Follow")
#                c.with("disabled",  Track.map(vehicle_available, func(v): return !v))
                c.with("theme_type_variation", "ButtonPrimaryActive")
#                c.with("button_pressed", is_orbitting)
                c.on("toggled", func(toggled):
#                    if is_orbitting.value != c.node().button_pressed:
#                        c.node().button_pressed = is_orbitting.value
                        toggle_orbit.emit()
                )
            )
        )
    )
    c.child(func(c: Ctx):
        c.inherits(VBoxContainer)
        c.child(func(c: Ctx):
            c.inherits(Label)
            c.with("text", "Attachments")
        )
        c.child_opt(Ui.map_child(Track.value(false), func(has_attachments): return func(c: Ctx):
            if has_attachments:
                c.inherits(Widgets.item_list(Track.array([]), active_attachment, func(v, i): return func(c: Ctx): 
                    var is_active = Track.combine_map([i, active_attachment], func(i, active): return i == active)
                    c.inherits(VBoxContainer)
                    c.child(func(c: Ctx):
                        c.inherits(Label)
                        c.with("text", "TODO")
                        c.with("vertical_alignment", VERTICAL_ALIGNMENT_CENTER)
                        c.with("size_flags_vertical", SIZE_EXPAND_FILL)
                    )
                    c.child_opt(Ui.map_child(is_active, func(v): return func(c: Ctx):
                        if v: c.inherits(func(c: Ctx): assert(false, "TODO"))
                    ))
                ))
            else:
                c.inherits(Label)
                c.with("text", "No Attachments")
                c.with("theme_override_colors/font_color", Color.GRAY)
                c.with("horizontal_alignment", HORIZONTAL_ALIGNMENT_CENTER)
        ))
    )
    c.child(func(c: Ctx):
        c.inherits(Control)
        c.with("size_flags_vertical", SIZE_EXPAND_FILL)
    )
    c.child(func(c: Ctx):
        c.inherits(HBoxContainer)
        c.child(func(c: Ctx):
            c.inherits(Widgets.button())
            c.with("text", "Compile")
            c.with("disabled", is_building)
            c.with("theme_type_variation", "ButtonPrimary")
            c.on("pressed", func(): compile_sketch.emit())
        )
        c.child(func(c: Ctx):
            c.inherits(Widgets.button())
            c.with("text", "Log")
            c.with("disabled", Track.combine_map([is_building, has_build_log], func(a,b): return !(a || b)))
            c.with("toggle_mode", true)
            c.with("theme_type_variation", "ButtonPrimaryActive")
            c.with("size_flags_horizontal", SIZE_EXPAND_FILL)
            c.on(log_window_open.changed, func(_w,_h): 
                c.node().set_pressed_no_signal(log_window_open.value())
            )
            c.on("pressed", func():
                # trigger a respawn
                log_window_open.change(false)
                log_window_open.change(true)
                c.node().set_pressed_no_signal(true)
            )
        )
        c.child(func(c: Ctx):
            c.inherits(Widgets.button())
            c.with("text", "Serial")
            c.with("disabled", Track.map(board_active, func(v): return !v))
            c.with("size_flags_horizontal", SIZE_EXPAND_FILL)
            c.with("toggle_mode", true)
            c.with("theme_type_variation", "ButtonPrimaryActive")
#            c.use_now(serial_window_open, func():.node().set_pressed_no_signal(serial_window_open.value))
            c.on("pressed", func():
                # trigger a respawn
#                serial_window_open.value = false
#                serial_window_open.value = true
                c.node().set_pressed_no_signal(true)
            )
        )
        c.child(func(c: Ctx):
            c.inherits(Widgets.button())
            c.with("text", "R")
            c.with("minimum_size", Vector2(36, 36))
            c.with("theme_type_variation", "ButtonWarn")
            c.on("pressed", func(): remove_self.emit())
        )
    )
    c.child_opt(Ui.map_child(Track.dedup(log_window_open), func(v): return func(c: Ctx):
        if v:
            var minimum_size := Vector2(640, 360)
            c.inherits(Widgets.window(log_window_open))
            c.with("title", Track.map(sketch_path, func(p): return "\"%s\" Logs" % p.get_file()))
            c.with("min_size",minimum_size)
            c.child(func(c: Ctx):
                c.inherits(PanelContainer)
                c.with("size", minimum_size)
                c.on("tree_entered", func(): c.node().set_anchors_preset(Control.PRESET_WIDE))
                c.child(LogWindow.log_window(build_log, Track.value("do the log")))
            )
    ))
#    c.children(Ui.child_if(Track.dedup(serial_window_open), func(c: Ctx):
#        var minimum_size := Vector2(640, 360)
#        c.inherits(Widgets.window(serial_window_open))
#        c.with("title", "Serial IO")
#        c.with("min_size", minimum_size)
#        c.child(func(c: Ctx):
#            c.inherits(PanelContainer)
#            c.with("size", minimum_size)
#            c.on("tree_entered", func():.node().set_anchors_preset(Control.PRESET_WIDE))
#            c.child(func(c: Ctx):
#                c.inherits(SerialWindow.serial_window(uart_in))
#                c.on("write", func(st):
#                    print(hardware_state.hardware)
#                    uart_puller.value.write(st)
#                )
#            )
#        )
#    ))



