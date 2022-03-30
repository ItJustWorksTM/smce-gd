class_name Widgets


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
    
    c.child_opt(Ui.map_children(items, func(i, item): return func(c: Ctx):
        c.inherits(ItemButton)
        c.with("mouse_default_cursor_shape", Control.CURSOR_POINTING_HAND)
        c.with("active", Track.combine_map(
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
#        print("childing")
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
