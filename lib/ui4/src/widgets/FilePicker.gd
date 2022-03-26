class_name FilePicker
extends Control

enum { SELECT_FILE, SELECT_DIR, SELECT_ANY, SAVE_FILE }

enum { KIND_FILE, KIND_DIR, KIND_NONE }

static func filepicker(mode = Ui.value(SELECT_FILE), user_filters = Ui.value([["Any", ["*.*"]]]), path = Ui.value(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS))): return func(ctx: Ctx):
	
	var object = ctx.inherits(PanelContainer).object()
	var completed = Fn.make_signal(object, "completed")
	var cancelled = Fn.make_signal(object, "cancelled")
	
	var fs_items = TrackedVec.new([])
	var selected_index = Ui.dedup_value(-1)
	
	var save_name = Ui.value("my_file.ino")
	
#	var selected_item = Ui.map(selected_index, func(i): return fs_items.index(i) if i > -1 else "")
	var selected_path = Ui.combine_map([selected_index, path], func(si, p):
		if si > -1 && si < fs_items.size():
			return p.plus_file(fs_items.index(si))
	)
	
	var active_filter = Ui.value(0)
	var filter = Ui.combine_map([user_filters, active_filter], func(fls, i):
		return fls[i][1] if i >= 0 else []
	)
	var filters = Ui.map(user_filters, func(f):
		var ret = []
		for v in f: ret.append(v[0] + " " + str(v[1]))
		return ret
	)
	
	var selected_kind = Ui.map(selected_path, func(p):
		if p == null: return KIND_NONE
		else: return KIND_DIR if Fs.dir_exists(p) else KIND_FILE
	)

	var open_disabled = Ui.combine_map([selected_kind, mode], func(v, mode):
		if v == KIND_NONE: return true
		match [mode, v]:
			[SELECT_FILE, KIND_FILE]: return false
			[SELECT_DIR, KIND_DIR]: return false
			[SELECT_ANY, _]: return false
			SAVE_FILE:
				Fn.unreachable()
				return true
			_: return true
	)
	
	var at_root = Ui.map(path, func(path): return path == path.get_base_dir())
	
	var update_items = func():
		fs_items.clear()
		fs_items.append_array(Fs.list_files(path.value, true, false, true))
		fs_items.append_array(Fs.list_files(path.value, true, true, false, filter.value))
	
	var activate_item = func(i):
		var next =  path.value.plus_file(fs_items.index(i))
		if Fs.dir_exists(next): path.value = next
		else: completed.emit(next)
	
	var pop_path = func():
		if at_root.value: return
		path.value = Fs.trim_trailing(path.value).get_base_dir()
	
	update_items.call()
	
	ctx \
	.label("FilePicker") \
	.with("minimum_size", Vector2(563, 330)) \
	.use([path, active_filter], update_items) \
	.child(func(ctx): ctx \
		.inherits(VBoxContainer) \
		.with("size_flags_horizontal", SIZE_EXPAND_FILL) \
		.child(func(ctx): ctx \
			.inherits(HBoxContainer) \
			.with("size_flags_horizontal", SIZE_EXPAND_FILL) \
			.child(func(ctx): ctx \
				.inherits(Widgets.button()) \
				.with("text", "Cancel") \
				.on("pressed", func(): cancelled.emit()) \
			) \
			.children(Ui.map_child(mode, func(mode): return func(ctx):
				if mode != SAVE_FILE: ctx \
					.inherits(Widgets.label((func():
						match mode:
							SELECT_FILE: return "Select a File"
							SELECT_DIR: return "Select a Directory"
							SELECT_ANY: return "Select a File or Directory"
						pass \
					).call())) \
					.with("horizontal_alignment", HORIZONTAL_ALIGNMENT_CENTER) \
					.with("size_flags_horizontal", SIZE_EXPAND_FILL) \
				else: ctx \
					.inherits(HBoxContainer) \
					.with("size_flags_horizontal", SIZE_EXPAND_FILL) \
					.child(func(ctx): return ctx \
						.inherits(HBoxContainer) \
						.with("alignment", HBoxContainer.ALIGNMENT_CENTER) \
						.with("size_flags_horizontal", SIZE_EXPAND_FILL) \
						.child(func(ctx): return ctx \
							.inherits(Widgets.label("Name: ")) \
						) \
						.child(func(ctx): return ctx \
							.inherits(Widgets.line_edit(save_name)) \
							.with("minimum_size", Vector2(200, 0)) \
						) \
					) \
			)) \
			.child(func(ctx): ctx \
				.inherits(Widgets.button()) \
				.with("text", Ui.map(mode, func(mode):
					return "Save" if mode == SAVE_FILE else "Open" \
				)) \
				.with("theme_type_variation", "ButtonPrimary") \
				.with("size_flags_horizontal", SIZE_SHRINK_END) \
				.with("disabled", open_disabled) \
				.on("pressed", func(): completed.emit(selected_path.value))
			)
		) \
		.child(func(ctx): ctx \
			.inherits(VBoxContainer) \
			.with("size_flags_vertical", SIZE_EXPAND_FILL) \
			.child(func(ctx): ctx \
				.inherits(HBoxContainer) \
				.child(func(ctx): ctx \
					.inherits(Widgets.button()) \
					.with("text", "<") \
					.with("disabled", at_root) \
					.on("pressed", pop_path)
				) \
				.child(func(ctx): ctx \
					.inherits(Widgets.line_edit(path)) \
					.with("size_flags_horizontal", SIZE_EXPAND_FILL) \
				) \
			) \
			.child(func(ctx): ctx \
				.inherits(PanelContainer) \
				.with("size_flags_vertical", SIZE_EXPAND_FILL) \
				.child(func(ctx): ctx \
					.inherits(ScrollContainer) \
					.with("follow_focus", true) \
					.child(func(ctx): ctx \
						.inherits(Widgets.item_list(
							fs_items,
							selected_index,
							func(v,i): return func(ctx): ctx \
								.inherits(Label) \
								.with("text", v) \
								.with("vertical_alignment", VERTICAL_ALIGNMENT_CENTER) \
								.with("size_flags_vertical", SIZE_EXPAND_FILL) \
								.label("find me") \
							)
						) \
						.with("size_flags_horizontal", SIZE_EXPAND_FILL) \
						.on("activated", activate_item)
					)
				) \
			) \
			.child(func(ctx): ctx \
				.inherits(BetterOptionButton) \
				.with("mouse_default_cursor_shape", Control.CURSOR_POINTING_HAND) \
				.with("size_flags_horizontal", SIZE_SHRINK_END) \
				.with("options", filters) \
				.with("selected", active_filter) \
				.on("item_selected", func(i): active_filter.value = i)
			)
		)
	)

