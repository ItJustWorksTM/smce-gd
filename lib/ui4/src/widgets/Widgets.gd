class_name Widgets extends Control


static func item_list(items: TrackedArrayBase, selected: Tracked, item_child: Callable): return func(c: Ctx): 
    c.inherits(VBoxContainer)
    c.with("name", "ItemList")
    c.with("rect_min_size", Vector2(100,50))
    
    c.on(items.changed, func(w,h):
        match h:
            Tracked.SET:
                selected.change.bind(-1)
            Tracked.REMOVED:
                if h >= items.size(): selected.change(-1)
            Tracked.INSERTED:
                if h == selected.value(): selected.change(selected.value() +1)
    )

    
    var on_selected := c.user_signal("selected")
    var on_activated := c.user_signal("activated")
    
    c.child_opt(Cx.map_children(items, func(i, item): return func(c: Ctx):
        c.inherits(ItemButton)
        c.with("mouse_default_cursor_shape", Control.CURSOR_POINTING_HAND)
        c.with("active", Cx.combine_map(
                [selected as Tracked, i as Tracked],
                func(s, i): return s == i
            )
        )
        c.on("selected", func():
            on_selected.emit(i.value())
            selected.change(i.value()) \
        )
        c.on("activated", func():
            on_activated.emit(i.value())
        )
        c.child(item_child.call(i, item))
    ))

static func label(text): return func(c: Ctx):
    c.inherits(Label)
    c.with("text", text)

static func button(): return func(c: Ctx):
    c.inherits(Button)
    c.with("mouse_default_cursor_shape", Control.CURSOR_POINTING_HAND)

static func line_edit(text: Tracked): return func(c: Ctx):
    c.inherits(LineEdit)
    c.with("text", text)
    c.on("text_changed", func(new_text):
        text.change(new_text)
        c.node().caret_column = text.value().length()
    )

static func window(open: Tracked): return func(c: Ctx):
    c.inherits(Window)
    c.with("visible", false)
    c.on("tree_entered", func(): c.node().popup_centered())
    c.on("close_requested", func():
        print("close??")
        open.change(false)
    )

static func popup_headerbar(
        title_widget_fn,
        activate_button_text: Tracked,
        activate_disabled: Tracked
    ): return func(c: Ctx):
    c.inherits(HBoxContainer)
    var cancel = c.user_signal("cancelled")
    var activate = c.user_signal("activated")
    
    c.with("size_flags_horizontal", SIZE_EXPAND_FILL)
    c.child(func(c: Ctx):
        c.inherits(Widgets.button())
        c.with("text", "Cancel")
        c.on("pressed", func(): cancel.emit())
    )
    c.child(func(c: Ctx):
        c.inherits(MarginContainer)
        c.with("size_flags_horizontal", SIZE_EXPAND_FILL)
        c.child_opt(Cx.map_child(title_widget_fn, func(fn): return fn))
    )
    c.child(func(c: Ctx):
        c.inherits(Widgets.button())
        c.with("text", activate_button_text)
        c.with("theme_type_variation", "ButtonPrimary")
        c.with("size_flags_horizontal", SIZE_SHRINK_END)
        c.with("disabled", activate_disabled)
        c.on("pressed", func(): activate.emit())
    )
    
    pass
