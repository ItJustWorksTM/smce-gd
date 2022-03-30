class_name SmceUiRoot
extends Control

static func smce_ui_root() -> Callable: return func(c: Ctx): 

    var picking_file = Track.value(false)
    var context_open = Track.value(false)
    
    var active_sketch = Track.value(-1)
    
    var file_mode = Track.value(FilePicker.SELECT_FILE)
    var filters = Track.value([["Arduino", ["*.ino", "*.pde"]], ["C++", ["*.cpp", "*.hpp", "*.hxx", "*.cxx"]], ["Any", ["*"]]])

    c.inherits(MarginContainer)
    
    var sketch_state: SketchState = c.use_state(SketchState)
    var board_state: BoardState = c.use_state(BoardState)
    
    c.child(func(c: Ctx):
        c.inherits(MultiInstance.multi_instance(active_sketch))
        c.on("create_sketch", func():
            picking_file.change(true)
        )
        c.on("open_context", func(): context_open.change(true))
    )
    c.child_opt(Ui.map_child(picking_file, func(v): return func(c: Ctx):
        if v:
            c.inherits(CenterContainer)
            c.child(func(c: Ctx):
                c.inherits(FilePicker.filepicker(file_mode, filters))
                c.on("completed", func(path: String):
                    picking_file.change(false)
                    var res: Result = sketch_state.add_sketch(path)
                    
                    if !res.is_ok():
                        return
                    
                    var bres = board_state.add_board(res.get_value())
                    
                    if !bres.is_ok():
                        return
                    
                    print("board id: ", bres.get_value())

                )
                c.on("cancelled", func(): picking_file.change(false))
            )
    ))
    c.child_opt(Ui.map_child(context_open, func(v): return func(c: Ctx):
        if v:
            c.inherits(CenterContainer)
            c.child(func(c: Ctx):
                var world_state := c.use_state(WorldEnvState) as WorldEnvState 
                c.inherits(PanelContainer)
                c.with("minimum_size", Vector2(300,200))
                c.child(func(c: Ctx):
                    c.inherits(VBoxContainer)
                    c.child_opt(Ui.map_children(world_state.worlds, func(i,v): return func(c: Ctx):
                        c.inherits(Widgets.button())
                        c.with("text", v)
                        c.on("pressed", func(): world_state.change_world(v.value))
                    ))
                )
            )
    ))
