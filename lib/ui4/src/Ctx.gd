class_name Ctx
extends Object

var _managed_node: Node = null
var _recreate
var _shared_state: Dictionary

var _to_disconnect: Array = []

func _init(recreate, shared_state: Dictionary = {}) -> void:
    self._recreate = recreate
    self._shared_state = shared_state
    self.inherits(recreate)
#    if is_initialized():
#        print("Ctx %s: initialized with %s" % [self, self.node()])

func node() -> Node:
    return _managed_node

func user_signal(signal_name: String) -> Signal:
    if assert_init(): return Signal()    
    if !self._managed_node.has_user_signal(signal_name):
        self._managed_node.add_user_signal(signal_name)
    return Signal(self._managed_node, signal_name)

func is_initialized() -> bool:
    return is_instance_valid(self) && is_instance_valid(_managed_node) && !_managed_node.is_queued_for_deletion()

func inherits(widget, args := []):
    assert(!self.is_initialized(), "Already initialized")
    
    if widget is Callable:
        widget.call(self)
        return
    
    if widget is Object && widget.has_method("new"):
        var vanilla_node = Fn.spread(widget.new).call(args)
        
        if !(vanilla_node is Node):
            vanilla_node.free()
            return
        
        self._managed_node = vanilla_node
        self._managed_node.set_meta("_kill", RefKill.new(self))
    
#    print("Ctx: created managed node: %s", self.node())
    
    return self

func child(widget):
    if assert_init(): return null
    
    var ctx = self.script.new(widget, self._shared_state)
    
    if ctx.is_initialized():
        self.node().add_child(ctx.node(), true)
        return self
    
    printerr("Ctx: child did not initialize, use child_opt if this is intended")
    ctx.free()
    
    return null

func child_opt(widget):
    if assert_init(): return null
    
    var placeholder = self.script.new(Node, self._shared_state)
    placeholder.node().name = "placeholder"
    
    self.node().add_child(placeholder.node(), true)
    
    widget.call(placeholder)
    
    return self

func with(property: String, value):
    if assert_init(): return null
    
    var value_now = value
    if value is Tracked:
        self.on(value.changed, self._property_changed.bind(value).bind(property))
        value_now = value.value()
    
    self.node().set_indexed(property, value_now)
    return self

func on(signal_like, cb: Callable):
    if assert_init(): return
        
    var sig = signal_like
    
    if sig is String:
        sig = Signal(self.node(), sig)
    
    if !(sig is Signal):
        printerr("Ctx: %s is not a signal" % sig)
        return
    
    sig.connect(cb)
    _to_disconnect.append([sig, cb])

    return self

func _property_changed(w,h,property: String, value: Tracked):
    if !is_initialized(): return
    var new_value = value.value()
    print("Ctx: %s::%s changed to \"%s\"" % [self.node(), property, new_value])
    self.node().set_indexed(property, new_value)

func register_state(script, node):
    if _shared_state.has(script):
        printerr("Ctx: State already exists, cannot register.")
    _shared_state[script] = node

func use_state(script) -> Object:
    return _shared_state.get(script)

func assert_init():
    if !self.is_initialized():
        printerr("Ctx: not initialized")
    return !self.is_initialized()

func _disconnect_signals():
    for sigcb in _to_disconnect:
        if is_instance_valid(sigcb[0].get_object()):
            sigcb[0].disconnect(sigcb[1])
#            print_debug("Ctx: disconnected signal %s from %s" % sigcb)
    _to_disconnect.clear()

func _notification(what):
    if what == NOTIFICATION_PREDELETE:
        _disconnect_signals()
#        print("Ctx: freed (%s) with %s" % [self, self._managed_node])
