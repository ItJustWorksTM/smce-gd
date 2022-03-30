class_name LogWindow
extends Control

static func log_window(build_log: Tracked, board_log: Tracked): return func(c: Ctx):
    
    var mode := Track.value_dedup(0)
    
    var text := Track.combine_map([build_log, board_log, mode], func(a,b,m):
        match m:
            0: return a
            1: return b
    )
    
    var btn = func(no): return func(c: Ctx):
        c.inherits(Widgets.button())
        c.with("text", "Build")
        c.with("minimum_size", Vector2(128, 0))
        c.with("toggle_mode", true)
        c.with("theme_type_variation", "ButtonClear")
        c.on(mode.changed, func(w,h):
            c.node().set_pressed_no_signal(no == mode.value())
        )
        c.node().set_pressed_no_signal(no == mode.value())
        c.on("pressed", func():
            mode.change(no)
        )
    
    c
    c.inherits(VBoxContainer)
    c.child(func(c: Ctx):
        c.inherits(MarginContainer)
        c.child(func(c: Ctx):
            c.inherits(HBoxContainer)
            c.with("alignment", HBoxContainer.ALIGNMENT_CENTER)
            c.child(func(c: Ctx):
                c.inherits(btn.call(0))
                c.with("text", "Build")
            )
            c.child(func(c: Ctx):
                c.inherits(btn.call(1))
                c.with("text", "Board")
            )
        )
        c.child(func(c: Ctx):
            c.inherits(Widgets.button())
            c.with("text", "To Clipboard")
            c.with("size_flags_horizontal", Control.SIZE_SHRINK_BEGIN)
            c.with("theme_type_variation", "ButtonClear")
            c.on("pressed", func(): DisplayServer.clipboard_set(text.value()))
        )
    )
    c.child(func(c: Ctx):
        c.inherits(PanelContainer)
        c.with("size_flags_vertical", SIZE_EXPAND_FILL)
        c.child(func(c: Ctx):
            c.inherits(RichTextLabel)
            c.with("scroll_following", true)
            c.with("selection_enabled", true)
            c.with("text", text)
        )
    )
