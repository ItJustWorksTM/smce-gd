class_name Notifications
extends Control

static func notifications() -> Callable: return func(c: Ctx):
    
    
    
    pass

static func notif(content: Callable, duration: Tracked) -> Callable: return func(c: Ctx):
    var init = Track.value(100.0)
    var doom = Track.tween(init, duration.value())
    var modul = Track.tween(Track.map_dedup(doom, func(i): return 0.0 if i == 0.0 else 1.0), 1.0)
    var vis = Track.map_dedup(modul, func(i): return i != 0)
    
    var prox = Track.value(Vector2(256, 70))
    var siz = Track.tween(prox, 0.1)
    
    c.inherits(MarginContainer)
    c.with("minimum_size", siz)
    c.use(siz, func(): print("siz: ", siz))
    c.with("visible", Track.map_dedup(siz, func(s): return s.y != 0))
    c.child(func(c: Ctx):
        c.inherits(PanelContainer)
        c.with("modulate:a", modul)
        c.with("visible", vis)
        c.on("tree_entered", func(): init.change(0.0))
        c.use(vis, func():
            if !vis.value():
                c.node().minimum_size = c.node().size
                prox.mutate(func(v):
                    v.y = 0
                    return v
                )
        )
        c.child(func(c: Ctx):
            c.inherits(VBoxContainer)
            c.child(content)
            c.child(func(c: Ctx):
                c.inherits(ProgressBar)
                c.with("minimum_size", Vector2(0, 4))
                c.with("percent_visible", false)
                c.with("value", doom)
            )
        )
    )
