class_name InstanceList
extends Control

    
static func instance_list(boards: TrackedArrayBase, active_sketch: Tracked) -> Callable: return func(c: Ctx):
    c.inherits(VBoxContainer)
    var minimized := Cx.value(false)
    var create_new := c.user_signal("create_new")
    var context_pressed := c.user_signal("context_pressed")
    
    c.with("alignment", VBoxContainer.ALIGNMENT_END)
    c.child(func(c: Ctx):
        c.inherits(PanelContainer)
        c.with("visible", Cx.map(minimized, func(v): return !v))
        c.child(func(c: Ctx):
            c.inherits(VBoxContainer)
            c.child(func(c: Ctx):
                c.inherits(Widgets.button())
                c.with("text", "<>")
                c.with("theme_type_variation", "ButtonClear")
                c.on("pressed", func(): context_pressed.emit())
            )
            c.child(func(c: Ctx):
                c.inherits(Control)
                c.with("minimum_size", Vector2(0,4))
            )
            c.child_opt(Cx.map_children(boards, func(i, __): return func(c: Ctx):
                var inverse = Cx.combine_map([boards as Tracked, i as Tracked], func(a,c):
                    return a.size() - c - 1 
                )
                
                var should_be_pressed = Cx.dedup(Cx.combine_map([boards as Tracked, active_sketch as Tracked, i as Tracked], func(a,b,c):
                    if b < 0: return false
                    var ret = (a.size() - b - 1) == c
                    return ret
                ))

                c.inherits(Widgets.button())
                c.with("text", Cx.map(inverse, func(i): return str(i +1)))
                c.with("theme_type_variation", "ButtonPrimaryActive")
                c.with("toggle_mode", true)
                c.on(should_be_pressed.changed, func(_w,_h): c.node().set_pressed_no_signal(should_be_pressed.value()))
                c.node().set_pressed_no_signal(should_be_pressed.value())
                c.on("toggled", func(toggled):
                    if active_sketch.value() == inverse.value() && !toggled:
                        active_sketch.change(-1)
                    elif toggled:
                        active_sketch.change(inverse.value())
                )\
            ))
            c.child(func(c: Ctx):
                c.inherits(Widgets.button())
                c.with("text", "+")
                c.with("theme_type_variation", "ButtonClear")
                c.with("focus_mode", 0)
                c.on("pressed", func(): create_new.emit())
            )
        )
    )
    c.child(func(c: Ctx):
        c.inherits(PanelContainer)
        c.with("minimum_size", Vector2(64, 32))
        c.child(func(c: Ctx):
            c.inherits(Widgets.button())
            c.with("toggle_mode", true)
            c.with("theme_type_variation", "ButtonClear")
            c.on(minimized.changed, func(_w,_h): c.node().set_pressed_no_signal(!minimized.value()))
            c.with("text", "...")
            c.on("toggled", func(toggled): minimized.change(!toggled))
        )
    )
