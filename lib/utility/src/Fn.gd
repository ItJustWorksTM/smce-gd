class_name Fn

static func apply(z: Callable, ctx: Variant):
    return z.call(ctx)

static func find_index(iterable, cb) -> int:
    for v in iterable:
        if cb.call(v):
            return v
    return -1

static func find_value(storage: Array, value: Variant) -> Variant:
    for v in storage:
        if Reflect.value_compare(v, value):
            return v
    return null

static func find(storage: Array, cb: Callable) -> Variant:
    for v in storage:
        if cb.call(v):
            return v
    return null

static func invert(v: bool): return !v

#static func make_signal(obj: Object, name: String) -> Signal:
#    obj.add_user_signal(name)
#    return Signal(obj, name)


static func _gen_vararg(count: int = 32):
    var arg_string = ""
    var convert_string = ""
    for v in count:
        arg_string += "_%d = Dummy" % v
        if v < count - 1:
            arg_string += ", "

        convert_string += """
        if !(_%d is Object && _%d == Dummy):
            ret.append(_%d)
        else:
            var cb = ret.pop_back()
            cb.call(ret)
            return""" % [v,v, v]

    var script = GDScript.new()
    script.source_code = """
class Dummy:
    pass

static func make_vararg():
    return func(%s):
        var ret: Array = []
        %s
    """ % [arg_string, convert_string]
    script.reload()

    return script

class _Ref:
    pass

static func squash(cb: Callable):
    var sc: Object = _Ref.new().script # "lazy static"
    if !sc.has_meta("gen"):
        sc.set_meta("gen", _gen_vararg())
    var obj = sc.get_meta("gen")

    return obj.make_vararg().bind(cb)

static func spread(cb: Callable) -> Callable:
    return func(args: Array):
        for i in args.size():
            cb = cb.bind(args[args.size() - i - 1])
        return cb.call()

static func connect_with_bail(sig: Signal, cb: Callable) -> void:
    var bridge = RefCountedValue.new()
    var cb2 = cb.bind(func():
        sig.disconnect(bridge.value)
    )

    bridge.value = cb2

    assert(sig.connect(cb2) == OK)


static func unreachable() -> void:
    assert(false, "unreachable")

