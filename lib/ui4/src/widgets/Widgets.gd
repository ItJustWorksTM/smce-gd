class_name Widgets


static func item_list(items: TrackedContainer, selected: ObservableMut, item_child: Callable): return func(ctx: Ctx): 
	var this := ctx.inherits(VBoxContainer).object()
	this.add_user_signal("selected")
	this.add_user_signal("activated")
	
	ctx \
		.label("ItemList") \
		.with("rect_min_size", Vector2(100,50)) \
		.use(items, func(t, i):
			match t:
				TrackedContainer.CLEARED:
					selected.value = -1
				TrackedContainer.ERASED:
					if i == items.size():
						selected.value = -1
				TrackedContainer.INSERTED:
					if i == selected.value: # TODO: untested :O
						selected.value += 1
			pass \
		) \
		.children(Ui.map_each_child(items, func(i, item):
			return func(ctx: Ctx):
				ctx \
					.inherits(ItemButton) \
					.with("mouse_default_cursor_shape", Control.CURSOR_POINTING_HAND) \
					.with("active", Ui.map(Ui.combined([selected, i]), func(args): return args[0] == args[1])) \
					.on("selected", func():
						this.emit_signal("selected", i.value)
						selected.value = i.value \
					) \
					.use(item, func(item): pass) \
					.on("activated", func():
						this.emit_signal("activated", i.value) \
					) \
					.child(item_child.call(item, i)) \
		))

static func label(text): return func(ctx: Ctx):
	ctx \
		.inherits(Label) \
		.with("text", text)

static func button(): return func(ctx: Ctx):
	ctx \
		.inherits(Button) \
		# TODO: implement proxy to intercept property setter
		.with("mouse_default_cursor_shape", Control.CURSOR_POINTING_HAND)

static func line_edit(text: ObservableValue): return func(ctx: Ctx):
	ctx \
		.inherits(LineEdit) \
		.with("text", text) \
		.on("text_changed", func(new_text):
			text.value = new_text
			ctx.object().caret_column = text.value.length() \
		)

static func window(open: ObservableMut): return func(ctx: Ctx):
	ctx \
		.inherits(Window) \
		.with("visible", false) \
		.on("tree_entered", func(): ctx.object().popup_centered()) \
		.on("close_requested", func():
			print("close??")
			open.value = false \
		)
