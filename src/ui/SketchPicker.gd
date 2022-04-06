class_name SketchPicker extends Control

static func sketch_picker(sketches: TrackedContainer): return func(c: Ctx):
    c.inherits(MarginContainer)
    
    var file_mode = Cx.value(FilePicker.SELECT_FILE)
    var filters = Cx.value([["Arduino", ["*.ino", "*.pde"]], ["C++", ["*.cpp", "*.hpp", "*.hxx", "*.cxx"]], ["Any", ["*"]]])

    var sketch_count = Cx.map(sketches, func(v): return v.size())
    var pick_file = Cx.value(false)
    
    var cancel := c.user_signal("cancelled")
    var complete := c.user_signal("completed")
    var create := c.user_signal("create")
    
    c.child(func(c: Ctx):
        c.inherits(FilePicker.filepicker(file_mode, filters))
        c.with("visible", pick_file)
        c.on("completed", func(path: String): 
            create.emit(path)
            pick_file.change(false)
        )
        c.on("cancelled", func(): pick_file.change(false))
    )
    c.child(func(c: Ctx):
        c.inherits(VBoxContainer)
        c.with("size_flags_vertical", SIZE_EXPAND_FILL)    
        c.with("visible", Cx.invert(pick_file))
        c.child(func(c: Ctx):
            c.inherits(Widgets.popup_headerbar(Cx.value(func(c: Ctx):
                c.inherits(Label)
                c.with("text", "Select Sketch")
                c.with("size_flags_horizontal", SIZE_EXPAND_FILL)
                c.with("horizontal_alignment", HORIZONTAL_ALIGNMENT_CENTER)
            ), Cx.value("Open"), Cx.value(false)))
            c.on("cancelled", func(): cancel.emit())
        )
        c.child(func(c: Ctx):
            c.inherits(PanelContainer)
            c.with("size_flags_vertical", SIZE_EXPAND_FILL)
            c.child(Widgets.item_list(sketches, Cx.value(-1), func(i, v): return func(c: Ctx):
                c.inherits(Label)
                var source = Cx.lens(v.info, "source")
                c.with("text", Cx.map(source, func(v: String): return v.get_file()))
                c.with("hint_tooltip", source) # TODO
            )) \
            .child(func(c: Ctx):
                c.inherits(Widgets.button())
                c.with("text", "+ Add New")
                c.with("theme_override_colors/font_color", Color.GRAY)
                c.with("theme_type_variation", "ButtonClear")
                c.on("pressed", func():
                    pick_file.change(true)
                )
            )
        )
    )
