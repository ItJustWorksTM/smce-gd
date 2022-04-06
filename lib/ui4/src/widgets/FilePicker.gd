class_name FilePicker
extends Control

enum { SELECT_FILE, SELECT_DIR, SELECT_ANY, SAVE_FILE }

enum { KIND_FILE, KIND_DIR, KIND_NONE }

static func filepicker(
        mode: Tracked = Cx.value(SELECT_FILE),
        user_filters: Tracked = Cx.value([["Any", ["*.*"]]]),
        path: Tracked = Cx.value("/home/ruthgerd/Documents/demo")
    ): return func(c: Ctx):
    
    var object := c.inherits(MarginContainer).node() as MarginContainer
    var completed := c.user_signal("completed")
    var cancelled := c.user_signal("cancelled")
    
    var selected_index := Cx.value_dedup(-1)
    
    var save_name := Cx.value("my_file.ino")
    
    var active_filter = Cx.value(0)
    var filter: Tracked = Cx.combine_map([user_filters, active_filter as Tracked], func(uf, a):
        return uf[a][1] if a >= 0 else []
    )

    var fs_items = Cx.combine_map([path, filter], func(p, f):
        var items = Fs.list_directory_items(p, f)
        var ret = items[0] + items[1]
        return ret
    )
    var selected_path = Cx.combine_map([selected_index as Tracked, path as Tracked, fs_items as Tracked], func(si, p, items):
        if si > -1 && si < items.size():
            return p.plus_file(items[si])
    )
    
    var mode_title = Cx.map(mode, func(mode): match mode:
        SELECT_FILE: return "Select a File"
        SELECT_DIR: return "Select a Directory"
        SELECT_ANY: return "Select a File or Directory"
        SAVE_FILE: return "Save File"
    )
    
    var mode_activate_label = Cx.map(mode, func(mode): return "Save" if mode == SAVE_FILE else "Open")
    
    var filters = Cx.map(user_filters, func(f):
        var ret = []
        for v in f: ret.append(v[0] + " " + str(v[1]))
        return ret
    )
    
    var selected_kind = Cx.map(selected_path, func(p):
        if p == null:
            return KIND_NONE
        else: return KIND_DIR if Fs.dir_exists(p) else KIND_FILE
    )

    var open_disabled = Cx.combine_map([selected_kind as Tracked, mode as Tracked], func(v, mode):
        if v == KIND_NONE: 
            return true
        match [mode, v]:
            [SELECT_FILE, KIND_FILE]: return false
            [SELECT_DIR, KIND_DIR]: return false
            [SELECT_ANY, _]: return false
            SAVE_FILE:
                Fn.unreachable()
                return true
            _: return true
    )
    
    var at_root = Cx.map(path, func(path): return path == path.get_base_dir())
    
    
    var activate_item = func(i):
        var next =  path.value().plus_file(fs_items.value()[i])
        if Fs.dir_exists(next): path.change(next)
        else: completed.emit(next)
    
    var pop_path = func():
        if at_root.value(): return
        path.mutate(func(v):
            return Fs.trim_trailing(v).get_base_dir()
        )
    
    
    var fu := Cx.array(fs_items.value())
    
    c.with("name", "FilePicker")
    c.on(fs_items.changed, func(w,h):
        print("updating fu items")
        fu.change(fs_items.value())
    )
    c.child(func(c: Ctx):
        c.inherits(VBoxContainer)
        c.with("size_flags_horizontal", SIZE_EXPAND_FILL)
        c.child(func(c: Ctx):
            c.inherits(Widgets.popup_headerbar(Cx.map(mode, func(mode): return func(c: Ctx):
                if mode != SAVE_FILE:
                    c.inherits(Widgets.label(mode_title))
                    c.with("horizontal_alignment", HORIZONTAL_ALIGNMENT_CENTER)
                    c.with("size_flags_horizontal", SIZE_EXPAND_FILL)
                else:
                    c.inherits(HBoxContainer)
                    c.with("size_flags_horizontal", SIZE_EXPAND_FILL)
                    c.child(func(c: Ctx):
                        c.inherits(HBoxContainer)
                        c.with("alignment", HBoxContainer.ALIGNMENT_CENTER)
                        c.with("size_flags_horizontal", SIZE_EXPAND_FILL)
                        c.child(func(c: Ctx): c.inherits(Widgets.label("Name: ")))
                        c.child(func(c: Ctx):
                            c.inherits(Widgets.line_edit(save_name))
                            c.with("minimum_size", Vector2(200, 0))
                        )
                    )
            ), mode_activate_label, open_disabled))
            c.on("cancelled", func(): cancelled.emit())
            c.on("activated", func(): completed.emit(selected_path.value()))
        )

        c.child(func(c: Ctx):
            c.inherits(VBoxContainer)
            c.with("size_flags_vertical", SIZE_EXPAND_FILL)
            c.child(func(c: Ctx):
                c.inherits(HBoxContainer)
                c.child(func(c: Ctx):
                    c.inherits(Widgets.button())
                    c.with("text", "<")
                    c.with("disabled", at_root)
                    c.on("pressed", pop_path)
                )
                c.child(func(c: Ctx):
                    c.inherits(Widgets.line_edit(path))
                    c.with("size_flags_horizontal", SIZE_EXPAND_FILL)
                )
            )
            c.child(func(c: Ctx):
                c.inherits(PanelContainer)
                c.with("size_flags_vertical", SIZE_EXPAND_FILL)
                c.child(func(c: Ctx):
                    c.inherits(ScrollContainer)
                    c.with("follow_focus", true)
                    c.child(func(c: Ctx):
                        c.inherits(Widgets.item_list(fu, selected_index, func(i,v): return func(c: Ctx): 
                            c.inherits(Label) 
                            c.with("text", v) 
                            c.with("vertical_alignment", VERTICAL_ALIGNMENT_CENTER)
                            c.with("size_flags_vertical", SIZE_EXPAND_FILL)
                            c.with("name", "find me")
                        ))
                        c.with("size_flags_horizontal", SIZE_EXPAND_FILL)
                        c.on("activated", activate_item)
                    )
                )
            )
            c.child(func(c: Ctx):
                c.inherits(BetterOptionButton)
                c.with("mouse_default_cursor_shape", Control.CURSOR_POINTING_HAND)
                c.with("size_flags_horizontal", SIZE_SHRINK_END)
                c.with("options", filters)
                c.with("selected", active_filter)
                c.on("item_selected", func(i): active_filter.change(i))
            )
        )
    )

