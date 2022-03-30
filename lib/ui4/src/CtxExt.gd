class_name CtxExt


static func create(cb: Callable) -> Node:
    var ctx := Ctx.new(cb)
    
    if !ctx.is_initialized():
        printerr("not initialized?")
        ctx.free()
        return null
    
    return ctx.node()
