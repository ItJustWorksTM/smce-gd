class_name InstanceControl
extends Control

static func instance_control(
        board: Tracked, sketch: Tracked, uart_in: Tracked, uart_out: Tracked
    ) -> Callable: return func(c: Ctx):
    
    var active_attachment = Cx.value(-1)
    var log_window_open = Cx.value(false)
    
    var serial_window_open = Cx.value(false)
    
    var board_state = Cx.lens(board, "state")
    var board_log = Cx.lens(board, "board_log")
    
    var board_available = Cx.map(board_state, func(state): return state != BoardState.BOARD_UNAVAILABLE)
    var board_active = Cx.map(board_state, func(state): return state == BoardState.BOARD_RUNNING || state == BoardState.BOARD_SUSPENDED)
    
#    var vehicle_available = Cx.map(vehicle_state, func(state): return true)
#    var has_attachments = Cx.dedup(Cx.map(attachments, func(vec): return !vec.is_empty()))
    
    var build_state: Tracked = Cx.lens(sketch, "build_state")
    var is_building: Tracked = Cx.map(build_state, func(state): return state == SketchState.BUILD_PENDING)
    var build_log: Tracked = Cx.lens(sketch, "build_log")
    var has_build_log: Tracked = Cx.map(build_log, func(s): return !s.is_empty())
    
    var sketch_path: Tracked = Cx.map(sketch, func(s): return s.sketch.source)
    
    c.inherits(VBoxContainer)
    
    var remove_self := c.user_signal("remove_pressed")
    var compile_sketch := c.user_signal("compile_sketch")
    var toggle_orbit := c.user_signal("toggle_orbit")
    
    var stop_board := c.user_signal("stop_board")
    var start_board := c.user_signal("start_board")
    var suspend_board := c.user_signal("suspend_board")
    var resume_board := c.user_signal("resume_board")
    
    
    var reset_vehicle := c.user_signal("reset_vehicle")
    var submit_uart := c.user_signal("submit_uart")
    
    var sketch_file = Cx.map(sketch, func(p): return p.sketch.source.get_file())

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
                c.with("text", Cx.map(board_active, func(s): return "Stop" if s else "Start" ))
                c.with("disabled", Cx.map(build_state, func(v): return v != SketchState.BUILD_SUCCEEDED))
                c.with("size_flags_horizontal", SIZE_EXPAND_FILL)
                c.with("theme_type_variation", Cx.map(board_active, func(v): return "ButtonWarn" if v else "ButtonPrimary"))
                c.on("pressed", func():
                    (stop_board if board_active.value() else start_board).emit()
                )
            )
            var can_resume = Cx.map(board_state, func(bs): return bs == BoardState.BOARD_SUSPENDED)
            c.child(func(c: Ctx):
                c.inherits(Widgets.button())
                c.with("text", Cx.map(can_resume, func(s): return "Resume" if s else "Suspend"))
                c.with("disabled", Cx.map(board_active, func(v): return !v))
                c.with("size_flags_horizontal", SIZE_EXPAND_FILL)
                c.on("pressed", func(): 
                    (resume_board if can_resume.value() else suspend_board).emit()
                )
            )
        )
    )
    c.child(func(c: Ctx):
        c.inherits(VBoxContainer)
        c.child(func(c: Ctx):
            c.inherits(Label)
#            c.with("text", Cx.map(vehicle_state, func(state): return "Vehicle Control" + (" (Frozen)" if state == WorldEnvState.VEHICLE_FROZEN else "")))
        )
        c.child(func(c: Ctx):
            c.inherits(HBoxContainer)
            c.child(func(c: Ctx):
                c.inherits(Widgets.button())
                c.with("text", "Reset Position")
                c.with("size_flags_horizontal", SIZE_EXPAND_FILL)
#                c.with("disabled", Cx.map(vehicle_available, func(v): return !v))
                c.on("pressed", func(): reset_vehicle.emit())
            )
            c.child(func(c: Ctx):
#                var is_orbitting = Cx.map(camera_state, func(state): return state == WorldEnvState.CAMERA_ORBITING)
                c.inherits(Widgets.button())
                c.with("toggle_mode", true)
                c.with("text", "Follow")
#                c.with("disabled",  Cx.map(vehicle_available, func(v): return !v))
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
        c.child_opt(Cx.map_child(Cx.value(false), func(has_attachments): return func(c: Ctx):
            if has_attachments:
                c.inherits(Widgets.item_list(Cx.array([]), active_attachment, func(v, i): return func(c: Ctx): 
                    var is_active = Cx.combine_map([i, active_attachment], func(i, active): return i == active)
                    c.inherits(VBoxContainer)
                    c.child(func(c: Ctx):
                        c.inherits(Label)
                        c.with("text", "TODO")
                        c.with("vertical_alignment", VERTICAL_ALIGNMENT_CENTER)
                        c.with("size_flags_vertical", SIZE_EXPAND_FILL)
                    )
                    c.child_opt(Cx.child_if(is_active, func(c: Ctx):
                        c.inherits(func(c: Ctx): assert(false, "TODO"))
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
            c.with("disabled", Cx.combine_map([is_building, has_build_log], func(a,b): return !(a || b)))
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
            c.with("disabled", Cx.map(board_active, func(v): return !v))
            c.with("size_flags_horizontal", SIZE_EXPAND_FILL)
            c.with("toggle_mode", true)
            c.with("theme_type_variation", "ButtonPrimaryActive")
            c.on(serial_window_open.changed, func(_w,_h): c.node().set_pressed_no_signal(serial_window_open.value()))
            c.on("pressed", func():
                # trigger a respawn
                serial_window_open.change(false)
                serial_window_open.change(true)
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
    c.child_opt(Cx.child_if(Cx.dedup(log_window_open), func(c: Ctx):
        var minimum_size := Vector2(640, 360)
        c.inherits(Widgets.window(log_window_open))
        c.with("title", Cx.map(sketch_path, func(p): return "\"%s\" Logs" % p.get_file()))
        c.with("min_size",minimum_size)
        c.child(func(c: Ctx):
            c.inherits(PanelContainer)
            c.with("size", minimum_size)
            c.on("tree_entered", func(): c.node().set_anchors_preset(Control.PRESET_WIDE))
            c.child(LogWindow.log_window(build_log, board_log))
        )
    ))
    c.child_opt(Cx.child_if(Cx.dedup(serial_window_open), func(c: Ctx):
        var minimum_size := Vector2(640, 360)
        c.inherits(Widgets.window(serial_window_open))
        c.with("title", "Serial IO")
        c.with("min_size", minimum_size)
        c.child(func(c: Ctx):
            c.inherits(PanelContainer)
            c.with("size", minimum_size)
            c.on("tree_entered", func(): c.node().set_anchors_preset(Control.PRESET_WIDE))
            c.child(func(c: Ctx):
                c.inherits(SerialWindow.serial_window(uart_in, uart_out))
                c.on("write", func(): submit_uart.emit())
            )
        )
    ))



