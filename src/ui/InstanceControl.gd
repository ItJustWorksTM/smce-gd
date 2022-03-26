class_name InstanceControl
extends Control

enum { BOARD_READY, BOARD_RUNNING, BOARD_SUSPENDED, BOARD_UNAVAILABLE }
enum { BUILD_PENDING, BUILD_SUCCEEDED, BUILD_FAILED, BUILD_UNKNOWN }
enum { VEHICLE_ACTIVE, VEHICLE_FROZEN, VEHICLE_UNAVAILABLE }
enum { CAMERA_ORBITING, CAMERA_FREE }

static func instance_control(
	sketch_path, board_state, build_state, build_log, vehicle_state, camera_state, attachments,
) -> Callable: return func(ctx: Ctx):
	
	var active_attachment = Ui.value(-1)
	var log_window_open = Ui.value(false)
	
	# TODO: make real..
	var serial_in = Ui.value("hello world")
	var serial_out = Ui.value("q")
	
	var serial_window_open = Ui.value(false)
	
	var board_available = Ui.map(board_state, func(state): return state != BOARD_UNAVAILABLE)
	var board_active = Ui.map(board_state, func(state): return state == BOARD_RUNNING || state == BOARD_SUSPENDED)
	
	var vehicle_available = Ui.map(vehicle_state, func(state): return state != VEHICLE_UNAVAILABLE)

	var has_attachments = Ui.dedup(Ui.map(attachments, func(vec): return !vec.is_empty()))
	
	var is_building = Ui.map(build_state, func(state): return state == BUILD_PENDING)
	var has_build_log = Ui.map(build_log, func(log): return !log.is_empty())
	
	
	ctx.inherits(VBoxContainer)
	var remove_self := ctx.user_signal("remove_pressed")
	var compile_sketch := ctx.user_signal("compile_sketch")
	var toggle_orbit := ctx.user_signal("toggle_orbit")
	var toggle_suspend := ctx.user_signal("toggle_suspend")
	var toggle_board := ctx.user_signal("toggle_board")
	var reset_vehicle := ctx.user_signal("reset_vehicle")
	
	ctx \
	.child(func(ctx): ctx \
		.inherits(Widgets.button()) \
		.with("text", sketch_path)
	) \
	.child(func(ctx): ctx \
		.inherits(VBoxContainer) \
		.child(func(ctx): ctx \
			.inherits(Label) \
			.with("text", "Board Control")
		) \
		.child(func(ctx): ctx \
			.inherits(HBoxContainer) \
			.child(func(ctx): ctx \
				.inherits(Widgets.button()) \
				.with("text", Ui.map(board_state, func(state):
					match state:
						BOARD_READY, BOARD_UNAVAILABLE: return "Start"
						BOARD_RUNNING, BOARD_SUSPENDED: return "Stop"
					pass \
				)) \
				.with("disabled", Ui.invert(board_available)) \
				.with("size_flags_horizontal", SIZE_EXPAND_FILL) \
				.with("theme_type_variation", Ui.map(board_active, func(v): return "ButtonWarn" if v else "ButtonPrimary")) \
				.on("pressed", func(): toggle_board.emit())
				
			) \
			.child(func(ctx): ctx \
				.inherits(Widgets.button()) \
				.with("text", Ui.map(board_state, func(state):
					match state:
						BOARD_SUSPENDED: return "Resume"
						_: return "Suspend"
					pass \
				)) \
				.with("disabled", Ui.invert(board_active)) \
				.with("size_flags_horizontal", SIZE_EXPAND_FILL) \
				.on("pressed", func(): toggle_suspend.emit())
			)
		)
	) \
	.child(func(ctx): ctx \
		.inherits(VBoxContainer) \
		.child(func(ctx): ctx \
			.inherits(Label) \
			.with("text", Ui.map(vehicle_state, func(state): return "Vehicle Control" + (" (Frozen)" if state == VEHICLE_FROZEN else "")))
		) \
		.child(func(ctx): ctx \
			.inherits(HBoxContainer) \
			.child(func(ctx): ctx \
				.inherits(Widgets.button()) \
				.with("text", "Reset Position") \
				.with("size_flags_horizontal", SIZE_EXPAND_FILL) \
				.with("disabled", Ui.invert(vehicle_available)) \
				.on("pressed", func(): reset_vehicle.emit())
			) \
			.child(func(ctx):
				var is_orbitting = Ui.map(camera_state, func(state): return state == CAMERA_ORBITING)
				ctx \
				.inherits(Widgets.button()) \
				.with("toggle_mode", true) \
				.with("text", "Follow") \
				.with("disabled",  Ui.invert(vehicle_available)) \
				.with("theme_type_variation", "ButtonPrimaryActive") \
				.with("button_pressed", is_orbitting) \
				.on("toggled", func(toggled):
					if is_orbitting.value != ctx.object().button_pressed:
						ctx.object().button_pressed = is_orbitting.value
						toggle_orbit.emit()
				) \
			)
		)
	) \
	.child(func(ctx): ctx \
		.inherits(VBoxContainer) \
		.child(func(ctx): ctx \
			.inherits(Label) \
			.with("text", "Attachments")
		) \
		.children(Ui.map_child(has_attachments, func(has_attachments): return func(ctx):
			if has_attachments: ctx \
				.inherits(Widgets.item_list(attachments, active_attachment, func(v, i): return func(ctx): 
					var is_active = Ui.combine_map([i, active_attachment], func(i, active): return i == active)
					ctx \
					.inherits(VBoxContainer) \
					.child(func(ctx): ctx \
						.inherits(Label) \
						.with("text", Ui.inner_lens(v, "attachment_name")) \
						.with("vertical_alignment", VERTICAL_ALIGNMENT_CENTER) \
						.with("size_flags_vertical", SIZE_EXPAND_FILL)
					) \
					.children(Ui.child_if(is_active, Ui.inner_lens(v, "inspector").value)) \
				))
			else: ctx \
				.inherits(Label) \
				.with("text", "No Attachments") \
				.with("theme_override_colors/font_color", Color.GRAY) \
				.with("horizontal_alignment", HORIZONTAL_ALIGNMENT_CENTER) \
		))
	) \
	.child(func(ctx): ctx \
		.inherits(Control) \
		.with("size_flags_vertical", SIZE_EXPAND_FILL) \
	) \
	.child(func(ctx): ctx \
		.inherits(HBoxContainer) \
		.child(func(ctx): ctx \
			.inherits(Widgets.button()) \
			.with("text", "Compile") \
			.with("disabled", is_building) \
			.with("theme_type_variation", "ButtonPrimary") \
			.on("pressed", func(): compile_sketch.emit())
		) \
		.child(func(ctx): ctx \
			.inherits(Widgets.button()) \
			.with("text", "Log") \
			.with("disabled", Ui.combine_map([is_building, has_build_log], func(a,b): return !(a || b))) \
			.with("toggle_mode", true) \
			.with("theme_type_variation", "ButtonPrimaryActive") \
			.with("size_flags_horizontal", SIZE_EXPAND_FILL) \
			.use_now(log_window_open, func(): ctx.object().set_pressed_no_signal(log_window_open.value)) \
			.on("pressed", func():
				# trigger a respawn
				log_window_open.value = false
				log_window_open.value = true
				ctx.object().set_pressed_no_signal(true) \
			) \
		) \
		.child(func(ctx): ctx \
			.inherits(Widgets.button()) \
			.with("text", "Serial") \
			.with("disabled", Ui.invert(board_active)) \
			.with("size_flags_horizontal", SIZE_EXPAND_FILL) \
			.with("toggle_mode", true) \
			.with("theme_type_variation", "ButtonPrimaryActive") \
			.use_now(serial_window_open, func(): ctx.object().set_pressed_no_signal(serial_window_open.value)) \
			.on("pressed", func():
				# trigger a respawn
				serial_window_open.value = false
				serial_window_open.value = true
				ctx.object().set_pressed_no_signal(true) \
			) \
		) \
		.child(func(ctx): ctx \
			.inherits(Widgets.button()) \
			.with("text", "R") \
			.with("minimum_size", Vector2(36, 36)) \
			.with("theme_type_variation", "ButtonWarn") \
			.on("pressed", func(): remove_self.emit())
		)
	) \
	.children(Ui.child_if(Ui.dedup(log_window_open), func(ctx: Ctx):
		var minimum_size := Vector2(640, 360)
		ctx \
		.inherits(Widgets.window(log_window_open)) \
		.with("title", Ui.map(sketch_path, func(p): return "\"%s\" Logs" % p)) \
		.with("min_size",minimum_size) \
		.child(func(ctx): ctx \
			.inherits(PanelContainer) \
			.with("size", minimum_size) \
			.on("tree_entered", func(): ctx.object().set_anchors_preset(Control.PRESET_WIDE)) \
			.child(LogWindow.log_window(build_log, Ui.value("do the log")))
		)
	)) \
	.children(Ui.child_if(Ui.dedup(serial_window_open), func(ctx: Ctx):
		var minimum_size := Vector2(640, 360)
		ctx \
		.inherits(Widgets.window(serial_window_open)) \
		.with("title", "Serial IO") \
		.with("min_size", minimum_size) \
		.child(func(ctx): ctx \
			.inherits(PanelContainer) \
			.with("size", minimum_size) \
			.on("tree_entered", func(): ctx.object().set_anchors_preset(Control.PRESET_WIDE)) \
			.child(SerialWindow.serial_window(serial_in, serial_out))
		)
	))



