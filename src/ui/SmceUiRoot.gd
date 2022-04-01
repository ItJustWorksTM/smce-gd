class_name SmceUiRoot
extends Control

static func smce_ui_root() -> Callable: return func(c: Ctx): 

    var picking_file = Cx.value(false)
    var context_open = Cx.value(false)
    
    var active_sketch = Cx.value(-1)
    
    var file_mode = Cx.value(FilePicker.SELECT_FILE)
    var filters = Cx.value([["Arduino", ["*.ino", "*.pde"]], ["C++", ["*.cpp", "*.hpp", "*.hxx", "*.cxx"]], ["Any", ["*"]]])

    c.inherits(MarginContainer)
    
    var sketch_state: SketchState = c.get_state(SketchState).value()
    var board_state: BoardState = c.get_state(BoardState).value()
    
    c.child(func(c: Ctx):
        c.inherits(MultiInstance.multi_instance(active_sketch))
        c.on("create_sketch", func():
            picking_file.change(true)
        )
        c.on("open_context", func(): context_open.change(true))
    )
    c.child_opt(Cx.child_if(picking_file, func(c: Ctx):
        c.inherits(CenterContainer)
        c.child(func(c: Ctx):
            c.inherits(FilePicker.filepicker(file_mode, filters))
            c.on("completed", func(path: String):
                picking_file.change(false)
                var res: Result = sketch_state.add_sketch.call(path)
                
                if !res.is_ok():
                    return
                
                var bres = board_state.add_board.call(res.get_value())
                
                if !bres.is_ok():
                    return
                
                print("board id: ", bres.get_value())

            )
            c.on("cancelled", func(): picking_file.change(false))
        )
    ))
    c.child_opt(Cx.child_if(context_open, func(c: Ctx):
        c.inherits(CenterContainer)
        c.child_opt(Cx.use_states([WorldEnvState], func(wenv): return func(c: Ctx):
            c.inherits(PanelContainer)
            c.with("minimum_size", Vector2(300,200))
            if wenv:
                c.child(func(c: Ctx):
                    c.inherits(VBoxContainer)
                    c.child_opt(Cx.map_children(wenv.worlds, func(i,v): return func(c: Ctx):
                        c.inherits(Widgets.button())
                        c.with("text", v)
                        c.on("pressed", func(): wenv.change_world.call(v.value()))
                    ))
                )
            else:
                c.child(Widgets.label("This is broken!"))
        ))
    ))
