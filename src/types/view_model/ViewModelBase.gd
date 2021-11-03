#
#  ViewModelBase.gd
#  Copyright 2021 ItJustWorksTM
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

class_name ViewModelBase

var _bind := BindMap.new(self)
var _func_map := {}

# TODO: implement _get_property_list

func _get(property: String):
    var ret = get_nullable(property)

    if ret == null && _func_map.has(property):
        push_warning("sugar caveat: Calculated property `%s` exists but was null!" % property)
    return ret

func get_nullable(property: String):
    if _func_map.has(property):
        var ret = callv(property, _func_map[property].get_value())
        return ret
    return null

func bind() -> BindMap: return _bind

func conn(target: Object, sig: String, method: String, binds: Array = [], flags: int = 0):
    if target.connect(sig, self, method, binds, flags) != OK:
        push_error("Failed to connect to signal '%s'" % sig)
        assert(false)

func bind_change(property, object, method, binds: Array = []):
    var suffix := "_prop" if binds.empty() && Reflect.has_property(object, method) else ""
    if connect(changed_signal(property) + suffix, object, method, binds) != OK:
        push_error("tried to bind to nonexistent property. did you initialize it?")
        return
    _apply(get(property), object, method, binds)

func bind_dependent(property, value):
    if !(value is Array):
        value = [value]
    for method_desc in get_method_list():
        if method_desc["name"] == property && method_desc["args"].size() == value.size():
            _func_map[property] = ObserversObserver.new(value)
            _func_map[property].connect("changed", self, "_on_dependent_change", [property])
            add_user_signal(changed_signal(property))
            add_user_signal(changed_signal(property) + "_prop")
            return true
    return false

func changed_signal(property): return property + "_changed"

func _on_dependent_change(__, property):
    if has_user_signal(changed_signal(property)):
        var val = get(property)
        emit_signal(changed_signal(property), val)
        for connection in get_signal_connection_list(changed_signal(property) + "_prop"):
            _apply(val, connection["target"], connection["method"], connection["binds"])
    else:
        push_error("Something bad happened")

func _apply(val, target, method, binds):
    if binds.empty() && Reflect.has_property(target, method):
        target.set(method, val)
        return
    binds.push_front(val)
    target.callv(method, binds)


# TODO: technically, yield() provides a way to get all args as an array
func _fwd_sig_jump0(sig): emit_signal(sig)
func _fwd_sig_jump1(arg0, sig): emit_signal(sig, arg0)
func _fwd_sig_jump2(arg0, arg1, sig): emit_signal(sig, arg0, arg1)
func _fwd_sig_jump3(arg0, arg1, arg2, sig): emit_signal(sig, arg0, arg1, arg2)

func fwd_sig(obj: Object, sig: String, binds: Array = []):
    for r in obj.get_signal_list():
        if r.name == sig:
            if !has_signal(sig):
                add_user_signal(sig, r.args) # TODO: take binds into account
            var braindead = binds + [sig]
            var __ = obj.connect(sig, self, "_fwd_sig_jump%d" % (r.args.size() + binds.size()), braindead)
            # print("ADDED SIGNAL FORWARD FOR ", sig, binds + [sig], (braindead.size()), r.args.size(), binds.size())
            return
    push_error("Failed to forward signal `%s`!" % sig)
            


# experimental
class _State:
    var _inner

    func _init(inner): _inner = inner

    func _get(property):
        return _inner[property]

    func _set(property, value):
        print("set ", property, value)
        _inner[property] = value
        return true

var state
func set_state(_state):
    state = _State.new(_state)

func observe_(name):
    pass

func set_(state_desc):
    pass

func get_(state_desc):
    pass


func state():
    pass
