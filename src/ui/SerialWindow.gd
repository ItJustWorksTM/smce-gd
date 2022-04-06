class_name SerialWindow
extends Control


static func serial_window(in_buffer: Tracked, out_buffer: Tracked) -> Callable: return func(c: Ctx):
    c.inherits(VBoxContainer)

    var write = c.user_signal("write")

    c.child(func(c: Ctx):
        c.inherits(PanelContainer)
        c.with("size_flags_vertical", SIZE_EXPAND_FILL)
        c.child(func(c: Ctx):
            c.inherits(RichTextLabel)
            c.with("text", in_buffer)
            c.with("scroll_following", true)
        )
    )
    c.child(func(c: Ctx):
        c.inherits(HBoxContainer)
        c.child(func(c: Ctx):
            c.inherits(Widgets.line_edit(out_buffer))
            c.with("size_flags_horizontal", SIZE_EXPAND_FILL)
            c.on("text_submitted", func(__): write.emit())
        )
        c.child(func(c: Ctx):
            c.inherits(Widgets.button())
            c.with("text", "Submit")
            c.with("disabled", Cx.map(out_buffer, func(input): return input.length() == 0))
            c.with("theme_type_variation", "ButtonPrimary")
            c.on("pressed", func(): write.emit())
        )
    )
