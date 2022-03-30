class_name MultiInstance
extends Control


static func multi_instance(active_sketch: Tracked) -> Callable: return func(c: Ctx):
    
    c.inherits(MarginContainer)
    
    var board_state: BoardState = c.use_state(BoardState)
    var sketch_state: SketchState = c.use_state(SketchState)
    
    var boards := board_state.boards
    
    var world_state := c.use_state(WorldEnvState) as WorldEnvState
    
    var create_sketch := c.user_signal("create_sketch")
    var context_open := c.user_signal("open_context")
    
    var notifications := Track.array([])
    
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
                c.with("visible", Track.map(active_sketch, func(i): return i >= 0))
                c.with("minimum_size", Vector2(288, 0))
                c.child_opt(Ui.map_children(boards, func(i, inst): return func(c: Ctx):
                    # TODO: figure out what to do in this situation for TrackedVec...
                    c.inherits(InstanceControl.instance_control(inst))
                    c.with("visible", Track.combine_map([active_sketch as Tracked, i as Tracked], func(a, i): return a == i))
                    c.on("compile_sketch", func():
                        sketch_state.compile_sketch(i.value())
                    )
                    c.on("toggle_orbit", func(): 
                        notifications.push({ title = "shit", desc = "shit", dur = randf_range(0.5, 10)})
                        world_state.toggle_orbit(i.value())
                    )
                    c.on("toggle_suspend", func(): pass)
                    c.on("toggle_board", func(): 
                        var res = board_state.start_board(i.value())
                        
                        pass
                    )
                    c.on("reset_vehicle", func(): pass)
                    c.on("remove_pressed", func(): pass)
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
            c.child_opt(Ui.map_children(notifications, func(i, no): return func(c: Ctx):
                c.inherits(Notifications.notif(
                    func(c: Ctx):
                        c.inherits(VBoxContainer)
                        c.child(Widgets.label(Track.lens(no, "title")))
                        c.child(func(c: Ctx):
                            c.inherits(Widgets.label(Track.lens(no, "desc")))
                            c.with("autowrap_mode", Label.AUTOWRAP_WORD)
                        ),
                    Track.lens(no, "dur")
                ))
            ))
        )
    )
