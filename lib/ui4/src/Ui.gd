class_name Ui

static func map_child(tracked: Tracked, widget_fn: Callable): return func(placeholder: Ctx):
    var hook: Node = placeholder.node()
    var parent: Node = hook.get_parent()
    
    var previous := RefCountedValue.new()
    var reset = func():
        if is_instance_valid(previous.value):
            parent.remove_child(previous.value)
            previous.value.queue_free()

        var widget: Callable = widget_fn.call(tracked.value())
        var ctx := Ctx.new(widget, placeholder._shared_state)
        
        if !ctx.is_initialized():
            ctx.free()
            return
        
        hook.add_sibling(ctx.node())
        previous.value = ctx.node()
    
    placeholder.on(tracked.changed, func(_h,_w): reset.call())
    
    reset.call()

static func map_children(arr: TrackedArrayBase, widget_fn: Callable): return func(placeholder: Ctx):
    var hook: Node = placeholder.node()
    var parent: Node = hook.get_parent()
    
    var make_new = func(k):
        var container_index = Track.container_index(arr, k)
        var value = Track.map(
            container_index,
            func(v): 
                var ret = arr.value_at(v) if v >= 0 else null
                if ret == null:
                    pass
                return ret
        )
        
        var ret := Ctx.new(widget_fn.call(container_index, value), placeholder._shared_state)
        
        if !ret.is_initialized():
            ret.free()
            assert(false, "Each item needs to map to a valid child")
        
        return ret
    
    var remove_child = func(at):
        var to_delete = parent.get_child(at)
        parent.remove_child(to_delete)
        if is_instance_valid(to_delete):
            to_delete.queue_free()
    
    var reset = func():
        for k in arr.size():
            var node = make_new.call(arr.size() - k - 1)
            hook.add_sibling(node.node(), true)
    
    reset.call()
    
    placeholder.on(arr.changed, func(what, how):
        var at = how
        var base_index: int = hook.get_index()
        match what:
            Tracked.INSERTED:
                var node = make_new.call(at)
                assert(!node.assert_init())
                parent.get_child(base_index + at).add_sibling(node.node(), true)
            Tracked.REMOVED:
                remove_child.call(base_index + at + 1)
            Tracked.SET:
                for c in how:
                    remove_child.call(base_index + 1)
                reset.call()
    )
    

