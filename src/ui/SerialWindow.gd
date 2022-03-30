class_name SerialWindow
extends Control


static func serial_window(in_buffer: Tracked) -> Callable: return func(c: Ctx):
    c.inherits(VBoxContainer)

    var text_input = Track.value("")
    
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
            c.inherits(Label)
            c.with("text", "Queued: ")
        )
        c.child(func(c: Ctx):
            c.inherits(Label)
            c.with("text", "too hard")
        )
    )
    c.child(func(c: Ctx):
        c.inherits(HBoxContainer)
        c.child(func(c: Ctx):
            c.inherits(Widgets.line_edit(text_input))
            c.with("size_flags_horizontal", SIZE_EXPAND_FILL)
        )
        c.child(func(c: Ctx):
            c.inherits(Widgets.button())
            c.with("text", "Submit")
            c.with("disabled", Track.map(text_input, func(input): return input.length() == 0))
            c.with("theme_type_variation", "ButtonPrimary")
            c.on("pressed", func():
                var send = text_input.value
                text_input.value = ""
                write.emit(send)
            )
        )
    )

    pass
