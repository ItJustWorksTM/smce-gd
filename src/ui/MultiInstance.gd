class_name MultiInstance
extends Control


static func multi_instance(active_sketch: Observable) -> Callable: return func(ctx: Ctx):
    
    ctx.inherits(MarginContainer)
    
    var smce_state := ctx.use_state(BoardState) as BoardState
    var sketches := smce_state.sketches
    
    var world_state := ctx.use_state(WorldEnvState) as WorldEnvState
    
    var create_sketch := ctx.user_signal("create_sketch")
    var context_open := ctx.user_signal("open_context")
    
    var notifications := TrackedVec.new([])
    
    ctx \
    .with("theme_override_constants/margin_right", 10) \
    .with("theme_override_constants/margin_left", 10) \
    .with("theme_override_constants/margin_top", 10) \
    .with("theme_override_constants/margin_bottom", 10) \
    .use([sketches], func():
        if sketches.size() <= active_sketch.value:
            active_sketch.value = sketches.size() -1 \
    ) \
    .child(func(ctx): ctx \
        .inherits(HBoxContainer) \
        .with("theme_override_constants/seperation", 10) \
        .child(func(ctx): ctx \
            .inherits(VBoxContainer) \
            .with("alignment", VBoxContainer.ALIGNMENT_END) \
            .child(func(ctx): ctx \
                .inherits(PanelContainer) \
                .with("visible", Ui.map(active_sketch, func(i): return i >= 0)) \
                .with("minimum_size", Vector2(288, 0)) \
                .children(Ui.map_each_child(sketches, func(i, inst): return func(ctx): ctx \
                    # TODO: figure out what to do in this situation for TrackedVec...
                    .inherits(InstanceControl.instance_control(
                        Ui.lens(inst, "id"), Ui.lens(inst, "path"), Ui.lens(inst, "board"), Ui.lens(inst, "build"), Ui.lens(inst, "build_log"),
                        Ui.value(0), Ui.value(0), TrackedVec.new([])
                    )) \
                    .with("visible", Ui.combine_map([active_sketch, i], func(a, i): return a == i)) \
                    .on("compile_sketch", func(): smce_state.compile_sketch(inst.value.id)) \
                    .on("toggle_orbit", func(): 
                        notifications.push({ title = "shit", desc = "shit", dur = randf_range(0.5, 10)})
                        world_state.toggle_orbit(i.value) \
                    ) \
                    .on("toggle_suspend", func(): smce_state.toggle_suspend(i.value)) \
                    .on("toggle_board", func(): smce_state.toggle_board(inst.value.id)) \
                    .on("reset_vehicle", func(): world_state.reset_vehicle(i.value)) \
                    .on("remove_pressed", func(): smce_state.remove_sketch(i.value)) \
                ))
            )
        ) \
        .child(func(ctx): ctx \
            .inherits(InstanceList.instance_list(sketches, active_sketch)) \
            .on("create_new", func(): create_sketch.emit()) \
            .on("context_pressed", func(): context_open.emit())
        ) \
        .child(func(ctx): ctx \
            .inherits(Control) \
            .with("size_flags_horizontal", SIZE_EXPAND_FILL) \
        ) \
        .child(func(ctx): ctx \
            .inherits(VBoxContainer) \
            .with("alignment", VBoxContainer.ALIGNMENT_END) \
            .children(Ui.map_each_child(notifications, func(i, no): return func(ctx): ctx \
                .inherits(Notifications.notif(
                    func(ctx): ctx \
                        .inherits(VBoxContainer) \
                        .child(Widgets.label(Ui.lens(no, "title"))) \
                        .child(func(ctx): ctx \
                            .inherits(Widgets.label(Ui.lens(no, "desc"))) \
                            .with("autowrap_mode", Label.AUTOWRAP_WORD)
                        ),
                    Ui.lens(no, "dur")
                )) \
            ))
        ) \
    )
