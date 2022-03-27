class_name Ctx
extends Node

var current: Node
var recreate: Callable

var _state: Dictionary = {}
var _owned_state: Array = []

func _init(_current):
	self.current = _current
	self.recreate = Callable()

func inherits(script, args = []) -> Ctx:
	if script is Callable:
		script.call(self)
	elif script is Script && script.get_base_script() == load("res://lib/ui4/src/CtxExt.gd"):
		var restore = func(this):
			this.current = current
			this.recreate = recreate
			this._state = _state
		
		self.script = script
		restore.call()
		self.inherited()
	else:
		var new = Fn.spread(script.new).call(args)
		self.current = new
		self.current.set_meta("ctx", self)
	return self

func object() -> Control:
	return self.current

func child(cb) -> Ctx:
	if cb is Callable:
		var ctx = Ctx.new(null)
		ctx.recreate = cb
		ctx._state = self._state
		cb.call(ctx)
		
		self.current.add_child(ctx.current)
		
		return self
	elif cb is Observable:
		pass
		return self
	else:
		Fn.unreachable()
		return self

static func recr(this: Ctx) -> void:
	var ctx = Ctx.new(null)
	ctx._state = this._state
	ctx.recreate = this.recreate
	ctx._state = this._state
	ctx.recreate.call(ctx)
	
	if is_instance_valid(this.current):
		this.current.add_sibling(ctx.current)
		this.current.get_parent().remove_child(this.current)
		for type in this._owned_state:
			this._state[type].value = null
			this._state.erase(type)
		# TODO: all our children's CTX's wont be freed
		this.current.queue_free()
		this.free()

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

# TODO: make Observable
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

func register_state(type: Script, initial = null) -> Ctx:
	if initial == null: initial = type.new()
	if type in self._state && self._state[type].value != null:
		assert(false, "Already registered")
	self._state[type] = ObservableValue.new(initial)
	_owned_state.push_back(type)
	return self

func get_state(type: Script) -> Observable:
	return self._state.get(type)

func use_state(type: Script) -> Object:
	var state = get_state(type)
	if state == null: return null
	var this = self
	self.use(state, func(): Ctx.recr(this))
	return state.value

