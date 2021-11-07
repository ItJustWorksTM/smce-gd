



class S:
    var b = S.new()

class Basic:
    extends ViewModelBase

    class State:
        var vec = S.new()

    func double_state(val): return val * 2

    func _init():
        set_state(State.new())

        bind() \
            .double_state.dep([observe_(state().x.y.z)])

        bind() \
            .double_state.to(self, "handle_change")

        state.vec = 2

    func handle_change(val):
        pass

class C:
    var c = "zzz"
    var d = "yy"
class B:
    var b = C.new()
    var fund = 456

class A:
    var a = B.new()
    var fund = [123]

class M:

    var context = []

    var inner = A.new()

    func _init():
        assert("")

    func get_context():
        var ret = inner
        for prop in context:
            if prop in ret:
                ret = ret.get(prop)
            else:
                var latest = context.back()
                context = [latest]
                return inner.get(latest)
        return ret

    func _get(property):
        context.push_back(property)
        var y = get_context()
        print("get %s" % [property])
        if y is Object:
            return self
        return y

    func _set(property, value):
        print("set %s with %s" % [property, value])
        var ctx = get_context()
        if !(value is Object):
            ctx.set(property, value)
        context.pop_back()
        return true

class PropertyPath:
    var path = []
    func _get(property):
        path.push_back(property)
        return self

func get_(a):
    pass

func set_(a, some_value):
    pass

func observe_(a):
    pass

func state():
    return PropertyPath.new()

func test_view_model():

#    var basic = Basic.new()

    var m = M.new()
    m.fund[0] = "bruh"
    print(m.fund[0])
    return
    var l = PropertyPath.new()
    m.a = l
    print(m.context)
    print(m.a.path)

    var p = state().a.b.c
    var val = get_(p)
    val += 2
    set_(p, val)

    state().a.b.c += 123

    var observer = observe_(state().a.b.c)

    return Result.new().set_ok(null)

func get_node(a): pass
