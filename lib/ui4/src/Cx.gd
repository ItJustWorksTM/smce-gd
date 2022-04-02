class_name Cx

# Tracking utilities
static func value(val: Variant) -> TrackedValue: return TrackedValue.new(val)

static func array(val: Array) -> TrackedArray: return TrackedArray.new(val)

static func container_index(tracked: TrackedContainer, key) -> TrackedContainerItem:
    return TrackedContainerItem.new(tracked, key)

static func container_value(tracked: TrackedContainer, key) -> TrackedMap:
    return map(
        container_index(tracked, key),
        func(i): if i >= 0:
            return tracked.value_at(i)
    )

static func map(tracked: Tracked, transform: Callable) -> TrackedMap:
    return TrackedMap.new(tracked, transform)

static func combine(tracked: Array[Tracked]) -> TrackedCombine:
    return TrackedCombine.new(tracked)

# TODO: consider spread
static func combine_map(tracked: Array[Tracked], transform: Callable) -> TrackedMap:
    return map(combine(tracked), Fn.spread(transform))

static func transform(tracked: TrackedContainer, transform: Callable) -> TrackedTransform:
    return TrackedTransform.new(tracked, transform)

static func buffer(tracked: Tracked, amount: int) -> TrackedBuffer:
    return TrackedBuffer.new(tracked, amount)

static func dedup(tracked: Tracked) -> TrackedDedup:
    return TrackedDedup.new(tracked)

static func map_dedup(tracked: Tracked, transform: Callable) -> TrackedDedup:
    return dedup(map(tracked, transform))

static func value_dedup(val: Variant) -> TrackedDedup: return dedup(TrackedValue.new(val))

static func tween(target: Tracked, duration: float) -> TrackedTween:
    return TrackedTween.new(target, duration)

static func lens(tracked: Tracked, prop: String) -> TrackedLens:
    return TrackedLens.new(tracked, prop)

static func inner(tracked: Tracked) -> TrackedInner:
    assert(tracked.value() is Tracked)
    return TrackedInner.new(tracked)

# Tree manipulation
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

static func child_if(tracked: Tracked, widget_fn: Callable):
    return map_child(tracked, func(v): return func(c: Ctx): if v: c.inherits(widget_fn))

static func map_children(arr: TrackedArrayBase, widget_fn: Callable): return func(placeholder: Ctx):
    var hook: Node = placeholder.node()
    var parent: Node = hook.get_parent()
    
    var make_new = func(k):
        var container_index = container_index(arr, k)
        var value = map(container_index, func(v): if v != null: return arr.value_at(v))
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
                parent.get_child(base_index + at).add_sibling(node.node(), true)
            Tracked.REMOVED:
                remove_child.call(base_index + at + 1)
            Tracked.SET:
                for c in how:
                    remove_child.call(base_index + 1)
                reset.call()
    )

static func map_children_dict(dict: TrackedContainer, widget_fn: Callable): return func(placeholder: Ctx):
    var hook: Node = placeholder.node()
    var parent: Node = hook.get_parent()
    
    var node_map = {}
    
    var make_new = func(k):
        var container_index = container_index(dict, k)
        var value = map(container_index, func(v): if v != null: return dict.value_at(v))
        
        var ret := Ctx.new(widget_fn.call(container_index, value), placeholder._shared_state)
        
        if !ret.is_initialized(): ret.free()
        return ret
    
    var remove_child = func(at):
        var to_delete = node_map[at]
        parent.remove_child(to_delete)
        node_map.erase(at)
        if is_instance_valid(to_delete):
            to_delete.queue_free()
    
    var reset = func():
        node_map.clear()
        for k in dict.keys():
            var node = make_new.call(k)
            node_map[k] = node.node()
            hook.add_sibling(node.node(), true)
    
    reset.call()
    
    placeholder.on(dict.changed, func(what, how):
        var at = how

        var base_index: int = hook.get_index()
        match what:
            Tracked.INSERTED:
                var node = make_new.call(at)
                node_map[at] = node.node()
                parent.get_child(base_index + node_map.size() - 1).add_sibling(node.node(), true)
            Tracked.REMOVED:
                remove_child.call(at)
            Tracked.SET:
                for c in how: remove_child.call(c)
                reset.call()
    )

static func use_states(scripts, widget): return func(placeholder: Ctx):
    var states: Array[Tracked] = []
    for script in scripts:
        states.append(placeholder.get_state(script) as Tracked)
    return map_child(combine(states), Fn.spread(widget)).call(placeholder)
