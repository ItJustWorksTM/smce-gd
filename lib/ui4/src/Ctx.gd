class_name Ctx
extends Node

var current: Node
var recreate: Callable

func _init(_current):
	self.current = _current
	self.recreate = Callable()

func inherits(script) -> Ctx:
	if script is Callable:
		script.call(self)
		return self

	var new = script.new()
	self.current = new
	
#	self.current.set_meta("guard", ScopeGuard.new(func(): if is_instance_valid(new): new.free()))
	self.current.set_meta("ctx", self)
	
	return self

func object() -> Control:
	return self.current

func child(cb) -> Ctx:
	if cb is Callable:
		var ctx = Ctx.new(null)
		ctx.recreate = cb
		
		cb.call(ctx)
		
		self.current.add_child(ctx.current)
		
		return self
	else:
		Fn.unreachable()
		return self

static func recr(this: Ctx) -> void:
	var ctx = Ctx.new(null)
	ctx.recreate = this.recreate
	ctx.recreate.call(ctx)
	
	if is_instance_valid(this.current):
		this.current.add_sibling(ctx.current)
		this.current.get_parent().remove_child(this.current)
		# TODO: all our children's CTX's wont be freed
		this.current.queue_free()
		this.free()

# this needs to be baked further to be generic over what this does, e.g. the generic part is providing a manager hook
func children(ch: Callable) -> Ctx:
	var manager = Node.new()
	self.current.add_child(manager)
	
	ch.call(self, manager)
	
	return self

func with(prop_name, val) -> Ctx:
	if val is Observable:
		var this = self
		Fn.connect_lifetime(self.current, val.changed, func(): 
			this.current.set_indexed(prop_name,val.value) 
		)
		self.current.set_indexed(prop_name, val.value) 
	else:
		self.current.set_indexed(prop_name, val) 
	return self

# should take in observer args? https://github.com/TheRawMeatball/ui4/blob/main/examples/todomvc.rs#L128
func on(signal_name: String, callable: Callable) -> Ctx:
	assert((self.current.has_signal(signal_name) || self.current.has_user_signal(signal_name)), "Signal does not exist")
	
	Fn.connect_lifetime(self, Signal(self.current, signal_name), Fn.squash(func(args: Array):
		for arg in args:
			callable = callable.bind(arg)
		callable.call()
	))
	return self

func use(ob, cb: Callable) -> Ctx:
	if !(ob is Array):
		ob = [ob]
	
	for _ob in ob:
		var this = self # pretend this is ok
		Fn.connect_lifetime(self, _ob.changed, Fn.squash(func(args: Array):
			if is_instance_valid(this):
				Fn.spread(cb).call(args)
		))
	
	return self

func use_now(ob, cb: Callable) -> Ctx:
	self.use(ob, cb)
	
	cb.call()
	
	return self

func label(tx: String) -> Ctx:
	self.current.name = tx
	return self

func user_signal(signal_name: String) -> Signal:
	if !self.current.has_user_signal(signal_name):
		self.current.add_user_signal(signal_name)
	return Signal(self.current, signal_name)
