class_name MultiInstance
extends Control


static func multi_instance(active_sketch: Tracked) -> Callable: return func(c: Ctx):
    
    c.inherits(MarginContainer)
    
    var board_state: BoardState = c.get_state(BoardState).value()
    var sketch_state: SketchState = c.get_state(SketchState).value()
    var hardware_state: HardwareState = c.get_state(HardwareState).value()
    var world_state: WorldEnvState = c.get_state(WorldEnvState).value()
    
    var boards := board_state.boards
    
    var create_sketch := c.user_signal("create_sketch")
    var context_open := c.user_signal("open_context")
    
    var notifications := Cx.array([])
    
    c.with("theme_override_constants/margin_right", 10)
    c.with("theme_override_constants/margin_left", 10)
    c.with("theme_override_constants/margin_top", 10)
    c.with("theme_override_constants/margin_bottom", 10)
    
    c.on(boards.changed, func(w,h):
        if boards.size() <= active_sketch.value():
            active_sketch.change(boards.size() -1)
    )
    
    c.child(func(c: Ctx):
        c.inherits(HBoxContainer)
        c.with("theme_override_constants/seperation", 10)
        c.child(func(c: Ctx):
            c.inherits(VBoxContainer)
            c.with("alignment", VBoxContainer.ALIGNMENT_END)
            c.child(func(c: Ctx):
                c.inherits(PanelContainer)
                c.with("visible", Cx.map(active_sketch, func(i): return i >= 0))
                c.with("minimum_size", Vector2(288, 0))
                c.child_opt(Cx.map_children(boards, func(i, board): return func(c: Ctx):
                    var sketch_id = Cx.inner(Cx.lens(board, "attached_sketch"))
                    var sketch_maybe = Cx.map(sketch_id, func(id):
                        if id >= 0: return sketch_state.sketches.value_at(id)
                    )
                    
                    var uart_in = Cx.value("")
                    var uart_out = Cx.value("")
                    
                    c.inherits(InstanceControl.instance_control(board, sketch_maybe, uart_in, uart_out))
                    c.with("visible", Cx.combine_map(
                        [active_sketch as Tracked, i as Tracked],
                        func(a, i): return a == i
                    ))
                    
                    var uart_maybe = Cx.map(
                        Cx.container_value(hardware_state.hardware, i.value()),
                        func(hw): if hw: return hw.by_label.get("Gui Uart")
                    )
                    c.on(uart_maybe.changed, func(w,h): # TODO: disconnect on change
                        var uart = uart_maybe.value()
                        if uart == null: uart_in.change("")
                        else: c.on(uart.read, func(_r): uart_in.change(uart.history_in)) 
                    )
                    c.on("submit_uart", func():
                        var uart = uart_maybe.value()
                        if uart == null: return
                        uart.write(uart_out.value())
                        uart_out.change("")                        
                    )
                    c.on("compile_sketch", func(): sketch_state.compile_sketch.call(i.value()))
                    c.on("start_board", func(): board_state.start_board.call(i.value()))
                    c.on("stop_board", func(): board_state.stop_board.call(i.value()))
                    c.on("suspend_board", func(): board_state.suspend_board.call(i.value()))
                    c.on("resume_board", func(): board_state.resume_board.call(i.value()))
                ))
            )
        )
        c.child(func(c: Ctx):
            c.inherits(InstanceList.instance_list(boards, active_sketch))
            c.on("create_new", func(): create_sketch.emit())
            c.on("context_pressed", func(): context_open.emit())
        )
        c.child(func(c: Ctx):
            c.inherits(Control)
            c.with("size_flags_horizontal", SIZE_EXPAND_FILL)
        )
        c.child(func(c: Ctx):
            c.inherits(VBoxContainer)
            c.with("alignment", VBoxContainer.ALIGNMENT_END)
            c.child_opt(Cx.map_children(notifications, func(i, no): return func(c: Ctx):
                c.inherits(Notifications.notif(
                    func(c: Ctx):
                        c.inherits(VBoxContainer)
                        c.child(Widgets.label(Cx.lens(no, "title")))
                        c.child(func(c: Ctx):
                            c.inherits(Widgets.label(Cx.lens(no, "desc")))
                            c.with("autowrap_mode", Label.AUTOWRAP_WORD)
                        ),
                    Cx.lens(no, "dur")
                ))
            ))
        )
    )
