class_name SmceUiRoot
extends Control

static func smce_ui_root() -> Callable: return func(c: Ctx): 

    var picking_file = Cx.value(false)
    var context_open = Cx.value(false)
    
    var active_sketch = Cx.value(-1)

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
            c.inherits(PanelContainer)
            c.with("minimum_size", Vector2(563, 330))
            c.child(func(c: Ctx):
                c.inherits(SketchPicker.sketch_picker(sketch_state.sketches))
                c.on("cancelled", func(): picking_file.change(false))
                c.on("create", func(path: String):
                    sketch_state.add_sketch.call(path)
                )
            )
        )
    ))
    c.child_opt(Cx.child_if(context_open, WorldSwitch.world_switch()))
