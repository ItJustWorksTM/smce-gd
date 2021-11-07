
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

    func _init():
        var l = get_incoming_connections()[0]
        l.source.disconnect(l.signal_name, self, "_signal_callback")
        var res = yield(l.source, l.signal_name)
        if is_valid(true):
            resume(res)
        else:
            emit_signal("completed", null)

static func safe(fnstate: GDScriptFunctionState):
    fnstate.script = _SafeYield
    return fnstate

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
