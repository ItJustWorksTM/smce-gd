class_name SmceUiRoot
extends Control

static func smce_ui_root() -> Callable: return func(ctx: Ctx): 

	var picking_file = Ui.value(false)
	var context_open = Ui.value(false)
	
	var active_sketch = Ui.value(-1)
	
	var file_mode = Ui.value(FilePicker.SELECT_FILE)
	var filters = Ui.value([["Arduino", ["*.ino", "*.pde"]], ["C++", ["*.cpp", "*.hpp", "*.hxx", "*.cxx"]], ["Any", ["*"]]])

	ctx \
	.inherits(MarginContainer) \
	.child(func(ctx: Ctx): ctx \
		.inherits(MultiInstance.multi_instance(active_sketch)) \
		.on("create_sketch", func():
			picking_file.value = true \
		) \
		.on("open_context", func(): context_open.value = true)
	) \
	.children(Ui.child_if(picking_file, func(ctx): ctx \
		.inherits(CenterContainer) \
		.child(func(ctx): ctx \
			.inherits(FilePicker.filepicker(file_mode, filters)) \
			.on("completed", func(path: String):
				picking_file.value = false
				ctx.get_state(BoardState).value.add_sketch(path) \
#				sketches.push(make.call(path.get_file()))
#				active_sketch.value = sketches.size() - 1 \
			) \
			.on("cancelled", func(): picking_file.value = false)
		)
	)) \
	.children(Ui.child_if(context_open, func(ctx): ctx \
		.inherits(CenterContainer) \
		.child(func(ctx):
			var world_state := ctx.use_state(WorldEnvState) as WorldEnvState 
			ctx \
			.inherits(PanelContainer) \
			.with("minimum_size", Vector2(300,200)) \
			.child(func(ctx): ctx \
				.inherits(VBoxContainer) \
				.children(Ui.for_each_child(world_state.worlds, func(i,v): return func(ctx): ctx \
					.inherits(Widgets.button()) \
					.with("text", v) \
					.on("pressed", func(): world_state.change_world(v.value))
				)) \
			) \
		) \
	)) \
