class_name WorldSwitch extends Control


static func world_switch(): return func(c: Ctx):
    c.inherits(CenterContainer)
    c.child_opt(Cx.use_states([WorldEnvState], func(wenv): return func(c: Ctx):
        c.inherits(PanelContainer)
        c.with("minimum_size", Vector2(300,200))
        if wenv:
            c.child(func(c: Ctx):
                c.inherits(VBoxContainer)
                c.child_opt(Cx.map_children(wenv.worlds, func(i,v): return func(c: Ctx):
                    c.inherits(Widgets.button())
                    c.with("text", v)
                    c.on("pressed", func(): wenv.change_world.call(v))
                ))
            )
        else:
            c.child(Widgets.label("This is broken!"))
    ))
