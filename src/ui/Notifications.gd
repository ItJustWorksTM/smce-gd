class_name Notifications
extends Control

static func notifications() -> Callable: return func(ctx: Ctx):
    
    
    
    pass

static func notif(content: Callable, duration) -> Callable: return func(ctx: Ctx):
    var init = Ui.value(100.0)
    var doom = Ui.tween(init, duration.value)
    var modul = Ui.tween(Ui.map_dedup(doom, func(i): return 0.0 if i == 0.0 else 1.0), 1.0)
    var vis = Ui.map_dedup(modul, func(i): return i != 0)
    
    var prox = Ui.value(Vector2(256, 70))
    var siz = Ui.tween(prox, 0.1)
    
    
    ctx \
        .inherits(MarginContainer) \
        .with("minimum_size", siz) \
        .use(siz, func(): print("siz: ", siz)) \
        .with("visible", Ui.map_dedup(siz, func(s): return s.y != 0)) \
        .child(func(ctx): ctx \
            .inherits(PanelContainer) \
            .with("modulate:a", modul) \
            .with("visible", vis) \
            .on("tree_entered", func(): init.value = 0.0) \
            .use(vis, func():
                if !vis.value:
                    ctx.object().minimum_size = ctx.object().size
                    prox.value.y = 0 \
            ) \
            .child(func(ctx: Ctx): ctx \
                .inherits(VBoxContainer) \
                .child(content) \
                .child(func(ctx): ctx \
                    .inherits(ProgressBar) \
                    .with("minimum_size", Vector2(0, 4)) \
                    .with("percent_visible", false) \
                    .with("value", doom)
                )
            )
        ) \
