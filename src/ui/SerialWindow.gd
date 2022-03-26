class_name SerialWindow
extends Control


static func serial_window(in_buffer: Observable, out_buffer: ObservableMut) -> Callable: return func(ctx: Ctx):

	var text_input = Ui.value("")

	ctx \
	.inherits(VBoxContainer) \
	.child(func(ctx): ctx \
		.inherits(PanelContainer) \
		.with("size_flags_vertical", SIZE_EXPAND_FILL) \
		.child(func(ctx): ctx \
			.inherits(RichTextLabel) \
			.with("text", in_buffer) \
			.with("scroll_following", true) \
		)
	) \
	.child(func(ctx): ctx \
		.inherits(HBoxContainer) \
		.child(func(ctx): ctx \
			.inherits(Label) \
			.with("text", "Queued: ")
		) \
		.child(func(ctx): ctx \
			.inherits(Label) \
			.with("text", out_buffer)
		)
	) \
	.child(func(ctx): ctx \
		.inherits(HBoxContainer) \
		.child(func(ctx): ctx \
			.inherits(Widgets.line_edit(text_input)) \
			.with("size_flags_horizontal", SIZE_EXPAND_FILL) \
		) \
		.child(func(ctx): ctx \
			.inherits(Widgets.button()) \
			.with("text", "Submit") \
			.with("disabled", Ui.map(text_input, func(input): return input.length() == 0)) \
			.with("theme_type_variation", "ButtonPrimary") \
			.on("pressed", func():
				var send = text_input.value
				text_input.value = ""
				out_buffer.value += send \
			)
		)
	)

	pass
