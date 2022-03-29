class_name InstanceList
extends Control

    
static func instance_list(sketches: TrackedContainer, active_sketch: ObservableMut) -> Callable: return func(ctx: Ctx):
    ctx.inherits(VBoxContainer)
    var minimized := Ui.value(false)
    var create_new := ctx.user_signal("create_new")
    var context_pressed := ctx.user_signal("context_pressed")
    
    
    ctx \
    .with("alignment", VBoxContainer.ALIGNMENT_END) \
    .child(func(ctx): ctx \
        .inherits(PanelContainer) \
        .with("visible", Ui.invert(minimized)) \
        .child(func(ctx): ctx \
            .inherits(VBoxContainer) \
            .child(func(ctx): ctx \
                .inherits(Widgets.button()) \
                .with("text", "<>") \
                .with("theme_type_variation", "ButtonClear") \
                .on("pressed", func(): context_pressed.emit())
            ) \
            .child(func(ctx): ctx \
                .inherits(Control) \
                .with("minimum_size", Vector2(0,4))
            ) \
            .children(Ui.map_each_child(sketches, func(i, __): return func(ctx: Ctx):
                var inverse = Ui.combine_map([sketches, i], func(a,c):
                    return a.size() - c - 1 
                )
                
                var should_be_pressed = Ui.dedup(Ui.combine_map([sketches, active_sketch, i], func(a,b,c):
                    if b < 0: return false
                    var ret = (a.size() - b - 1) == c
                    return ret
                ))

                ctx \
                .inherits(Widgets.button()) \
                .with("text", Ui.map(inverse, func(i): return str(i +1))) \
                .with("theme_type_variation", "ButtonPrimaryActive") \
                .with("toggle_mode", true) \
                .use_now(should_be_pressed, func(): ctx.object().set_pressed_no_signal(should_be_pressed.value)) \
                .on("toggled", func(toggled):
                    if active_sketch.value == inverse.value && !toggled:
                        active_sketch.value = -1
                    elif toggled:
                        active_sketch.value = inverse.value
                )\
            )) \
            .child(func(ctx): ctx \
                .inherits(Widgets.button()) \
                .with("text", "+") \
                .with("theme_type_variation", "ButtonClear") \
                .with("focus_mode", 0) \
                .on("pressed", func(): create_new.emit())
            ) \
        )
    ) \
    .child(func(ctx): ctx \
        .inherits(PanelContainer) \
        .with("minimum_size", Vector2(64, 32)) \
        .child(func(ctx): ctx \
            .inherits(Widgets.button()) \
            .with("toggle_mode", true) \
            .with("theme_type_variation", "ButtonClear") \
            .use(minimized, func(): ctx.object().set_pressed_no_signal(!minimized.value)) \
            .with("text", "...") \
            .on("toggled", func(toggled): minimized.value = !toggled)
        )
    ) \
