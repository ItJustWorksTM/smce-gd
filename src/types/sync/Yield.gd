
class_name Yield

class _Yield:
    signal sig

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

    func _on_complete(value):
        _value = value
        _triggered = true
    
    func value():
        assert(_triggered)
        return _value


static func save_value(fnstate):
    return _Yield2.new(fnstate)
