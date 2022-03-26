class_name MultiInstance
extends Control


static func multi_instance(sketches: TrackedVec, active_sketch: Observable) -> Callable: return func(ctx: Ctx):
	
	ctx.inherits(MarginContainer)
	
	var remove_instance := ctx.user_signal("remove_pressed")
	var compile_sketch := ctx.user_signal("compile_sketch")
	var toggle_orbit := ctx.user_signal("toggle_orbit")
	var reset_vehicle := ctx.user_signal("reset_vehicle")
	var toggle_suspend := ctx.user_signal("toggle_suspend")
	var toggle_board := ctx.user_signal("toggle_board")
	var create_sketch := ctx.user_signal("create_sketch")
	
	ctx \
	.with("theme_override_constants/margin_right", 10) \
	.with("theme_override_constants/margin_left", 10) \
	.with("theme_override_constants/margin_top", 10) \
	.with("theme_override_constants/margin_bottom", 10) \
	.use([sketches], func():
		if sketches.size() <= active_sketch.value:
			active_sketch.value = sketches.size() -1 \
	) \
	.child(func(ctx): ctx \
		.inherits(HBoxContainer) \
		.with("theme_override_constants/seperation", 10) \
		.child(func(ctx): ctx \
			.inherits(VBoxContainer) \
			.with("alignment", VBoxContainer.ALIGNMENT_END) \
			.child(func(ctx): ctx \
				.inherits(PanelContainer) \
				.with("visible", Ui.map(active_sketch, func(i): return i >= 0)) \
				.with("minimum_size", Vector2(288, 0)) \
				.children(Ui.tracked_each(sketches, func(inst, i): return func(ctx): ctx \
					# TODO: figure out what to do in this situation for TrackedVec...
					.inherits(InstanceControl.instance_control(
						Ui.inner_lens(inst, "sketch_path"), Ui.inner_lens(inst, "board_state"), Ui.inner_lens(inst, "build_state"), Ui.inner_lens(inst, "build_log"),
						Ui.inner_lens(inst, "vehicle_state"), Ui.inner_lens(inst, "camera_state"), Ui.inner_lens(inst, "attachments").value
					)) \
					.with("visible", Ui.combine_map([active_sketch, i], func(a, i): return a == i)) \
					.on("compile_sketch", func(): compile_sketch.emit(i.value)) \
					.on("toggle_orbit", func(): toggle_orbit.emit(i.value)) \
					.on("toggle_suspend", func(): toggle_suspend.emit(i.value)) \
					.on("toggle_board", func(): toggle_board.emit(i.value)) \
					.on("reset_vehicle", func(): reset_vehicle.emit(i.value)) \
					.on("remove_pressed", func(): remove_instance.emit(i.value)) \
				))
			)
		) \
		.child(func(ctx): ctx \
			.inherits(InstanceList.instance_list(sketches, active_sketch)) \
			.on("create_new", func(): create_sketch.emit())
		) \
		.child(func(ctx): ctx \
			.inherits(Control) \
			.with("size_flags_horizontal", SIZE_EXPAND_FILL) \
		) \
		.child(func(ctx): ctx \
			.inherits(VBoxContainer) \
			
		) \
	)
