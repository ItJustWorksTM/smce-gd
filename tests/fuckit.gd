
class Contexted:
    var context = []

    var inner

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

    func _to_string(): return str(inner)

class Ref:
    signal value_changed()
    var value setget set_value, get_value

    func _init(v): value = v

    func set_value(v):
        value = v
        emit_signal("value_changed", v)

    func get_value(): return value

    func _to_string(): return str(value)


class Reactive:
    var _inner
    var _map := {}

    func _init(script):
        _inner = script

    func _insert(property):
        print("try insert ", property)
        if ! _map.has(property) && property in _inner:
            var val = _inner.get(property)

            if val is Object:
                val = Reactive.new(val)

            _map[property] = Ref.new(val)
        else:
            print("failed insert")

    func _get(property):
        if property in _inner:
            _insert(property)

            return _map[property].value

    func _set(property, value):
        if property in _inner:
            if value is Object && !(value is Reactive):
                value = Reactive.new(value)
            if ! _map.has(property):
                _map[property] = Ref.new(value)
            else:
                _map[property].value = value
            return true
        return false

    func _to_string():
        return str(_map)

    func observe(path):
        var p = path.path[0]
        path.path.pop_front()
        _insert(p)
        var ret = _map[p]

        if path.path.size() > 0:
            return ret.value.observe(path)
        print(ret)
        return ret

    func obsv():

        pass

class PropertyPath:
    var path = []
    func _get(property):
        path.push_back(property)
        return self

func _(): return PropertyPath.new()

class Z:
    var d = "not very creative"
    var z = "this is ZZZ"

class S:
    var a = "Nice"
    var b = 123
    var c = [1,2,3]
    var z

func hello(v):
    print("world ", v is Reactive)

func test_fuckit():

    var state = Reactive.new(S.new())
    var contexted = Contexted.new()
    contexted.inner = state

    state.z = 0

    state.z = Z.new()

    contexted.z.d = "poopie"

    print(contexted.context)

    print("I forgot why contexted access works.. ",contexted.z)
    print(contexted.context)

    print(state.z.get_script())
    print(contexted.z)


#    var wtf = state.observe(_().z)
#
#    wtf.connect("value_changed", self, "hello")
##
##    state.a = "bye"
##
##    state.c[2] = 4
#    state.z = S.new()
#
#    print(state.z)
#
#    state.observe(_().z.a).connect("value_changed", self, "hello")
#    state.z.z = Z.new()
#    state.z.z.d = "I hate this"
#    print(state)
#

    return Result.new().set_ok("Fuckit")
