class_name Ui
extends Control

static func make_ui_root(root: Callable) -> Node:
	var ctx = Ctx.new(null)
	ctx.recreate = root
	root.call(ctx)
	return ctx.current

static func value(val: Variant) -> ObservableValue:
	return ObservableValue.new(val)

static func dedup(obs: Observable) -> Dedup:
	return Dedup.new(obs)

static func dedup_value(val: Variant) -> DedupMut:
	return DedupMut.new(value(val))

static func map(obs: Observable, fun: Callable) -> Mapped:
	return Mapped.new(obs, fun)

static func map_dedup(obs: Observable, fun: Callable) -> Dedup:
	return dedup(map(obs, fun))

static func combined(obs: Array) -> Combined:
	return Combined.new(obs)

static func combine_map(obss: Array, fun: Callable) -> Mapped:
	return map(combined(obss), Fn.spread(fun))

static func tween(obs: Observable, time: float, trans = Tween.TRANS_LINEAR) -> Tweened:
	return Tweened.new(obs, time, trans)

static func invert(obs: Observable) -> Mapped:
	return map(obs, func(v): return !v)

static func inner(obs: ObservableMut) -> InnerMut:
	return InnerMut.new(obs)

static func lens(obs: ObservableMut, prop: String) -> LensMut:
	return LensMut.new(obs, prop)

static func inner_lens(ob, prop: String) -> InnerMut:
	return inner(lens(ob, prop))

class TrackedEach:
	
	var cb: Callable
	var f: TrackedVec
	



# so for this to make sense, the index passed in should also be an observable hmm
static func tracked_each(f: TrackedVec, cb: Callable) -> Callable:
	return func(this: Ctx, manager: Node) -> void:
		Fn.connect_lifetime(manager, f.vec_changed, func(t, i):
			if !is_instance_valid(manager) || manager.is_queued_for_deletion(): return
			var parent = manager.get_parent()
			var child_n = parent.get_children().find(manager)
			match t:
				TrackedVec.INSERT:
					var pos = parent.get_child(child_n + i)
					var tmp = f.index_r(i)
					var ctx = Ctx.new(null)
					ctx.recreate = cb.call(tmp[0], tmp[1])
					ctx.recreate.call(ctx)
					pos.add_sibling(ctx.current)
				TrackedVec.REMOVED:
					parent.remove_child(parent.get_child(child_n + i + 1))
				TrackedVec.CLEAR:
					for j in i:
						parent.remove_child(parent.get_child(child_n + i - j))
		)
		
		f.each_r(func(v, i): this.child(cb.call(v,i)))

static func map_child(ob: Observable, cb: Callable) -> Callable:
	return func(this: Ctx, manager: Node) -> void:
		Fn.connect_lifetime(manager, ob.changed, func():
			var parent = manager.get_parent()
			var child_n = parent.get_children().find(manager)
			var ct = parent.get_child(child_n + 1).get_meta("ctx")
			ct.recreate = cb.call(ob.value)
			Ctx.recr(ct)
		)
		this.child(cb.call(ob.value))

static func child_if(ob: Observable, cb: Callable) -> Callable:
	return Ui.map_child(ob, func(v): return func(ctx):
		if v: ctx.inherits(cb)
		else: ctx.inherits(Control).with("visible", false)
	)
