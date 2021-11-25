
class_name Yield

class _Yield:
    signal sig()

    func defer_sig():
        call_deferred("emit_signal", "sig")

        reference()
        connect("sig", self, "_dispose")
        return self

    func _dispose():
        call_deferred("_dispose_impl")

    func _dispose_impl():
        unreference()

static func yield():
    yield(_Yield.new().defer_sig(), "sig");

class _Yield2:

    var _triggered = false
    var _value

    func _init(fnstate):
        fnstate.connect("completed", self, "_on_complete")

    func _on_complete(value = null):
        _value = value
        _triggered = true

    func value():
        assert(_triggered)
        return _value


static func save_value(fnstate):
    return _Yield2.new(fnstate)


class _SafeYield:
    extends GDScriptFunctionState

    static func coroutine(): return yield()

    func _init():
        var l = get_incoming_connections()[0]

        var routine = coroutine()

        RAII.on_death(l.source, routine, "resume", [null])
        l.source.disconnect(l.signal_name, self, "_signal_callback")

        # https://github.com/godotengine/godot/blob/3.x/modules/gdscript/gdscript_function.cpp#L1740
        l.source.connect(l.signal_name, routine, "_signal_callback", [routine, routine, routine])

        var res = yield(routine, "completed")

        if res != null:
            res.pop_back()
            res.pop_back()
        if is_instance_valid(l.source):
            l.source.disconnect(l.signal_name, routine, "_signal_callback")
        if is_valid(true):
            resume(res)
        else:
            emit_signal("completed", null)
        set_block_signals(true)
        

static func safe(fnstate: GDScriptFunctionState):
    fnstate.script = _SafeYield
    return fnstate

static func _sig(obj, sig):
    return yield(obj, sig)

static func sig(obj: Object, sig: String):
    return safe(_sig(obj, sig))

class _Yield3:
    signal completed()
    func resume(n):
        emit_signal("completed", n)
        set_block_signals(true)

static func many(obj: Object, signals: Array):
    var state = _Yield3.new()
    
    for sig in signals:
        var __ = obj.connect(sig, state, "resume", [sig])
    return state

# idea: pollable fnstate?
