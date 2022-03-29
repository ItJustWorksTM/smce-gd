class_name LogWindow
extends Control

static func log_window(build_log: Observable, board_log: Observable): return func(ctx):
    
    var mode = Ui.dedup_value(0)
    
    var text = Ui.combine_map([build_log, board_log, mode], func(a,b,m):
        match m:
            0: return a
            1: return b
    )
    
    var btn = func(no): return func(ctx): ctx \
        .inherits(Widgets.button()) \
        .with("text", "Build") \
        .with("minimum_size", Vector2(128, 0)) \
        .with("toggle_mode", true) \
        .with("theme_type_variation", "ButtonClear") \
        .use_now(mode, func():
            ctx.object().set_pressed_no_signal(no == mode.value) \
        ) \
        .on("pressed", func():
            mode.value = no \
        )
    
    ctx \
    .inherits(VBoxContainer) \
    .child(func(ctx): ctx \
        .inherits(MarginContainer) \
        .child(func(ctx): ctx \
            .inherits(HBoxContainer) \
            .with("alignment", HBoxContainer.ALIGNMENT_CENTER) \
            .child(func(ctx): ctx \
                .inherits(btn.call(0)) \
                .with("text", "Build")
            ) \
            .child(func(ctx): ctx \
                .inherits(btn.call(1)) \
                .with("text", "Board")
            )
        ) \
        .child(func(ctx): ctx \
            .inherits(Widgets.button()) \
            .with("text", "To Clipboard") \
            .with("size_flags_horizontal", Control.SIZE_SHRINK_BEGIN) \
            .with("theme_type_variation", "ButtonClear") \
            .on("pressed", func(): DisplayServer.clipboard_set(text.value))
        ) \
    ) \
    .child(func(ctx): ctx \
        .inherits(PanelContainer) \
        .with("size_flags_vertical", SIZE_EXPAND_FILL) \
        .child(func(ctx): ctx \
            .inherits(RichTextLabel) \
            .with("scroll_following", true) \
            .with("selection_enabled", true) \
            .with("text", text)
        )
    )
