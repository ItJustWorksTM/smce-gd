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
var _invoke := InvokeMap.new(self)

var _props: Dictionary = {}
var _actions: Dictionary = {}

# TODO: implement _get_property_list

func actually_init(props = {}, actions = {}, args = []):
    _props = props
    _actions = actions
    callv("_on_init", args)

func _get(property: String):
    if property in _props:
        return _props[property]
    if property in _actions:
        return _actions[property]
    if has_method(property):
        _actions[property] = action(property)
        return _actions[property]

    
func bind() -> BindMap: return _bind
func props() -> Dictionary: return _props

func invoke(): return _invoke
func actions() -> Dictionary: return _actions

func bind_change(property, object, method, binds: Array = []):
    if ! property in _props:
        push_error("Can't bind change of non existent property `%s`" % property)
        return
    _props[property].bind_change(object, method, binds)
    print("Bound change `%s` to `%s`" % [property, method])

func bind_dependent(property, value):
    if property in _props:
        push_error("Can't create calculated property `%s`: already exists" % property)
        return false
    for method_desc in get_method_list():
        if method_desc["name"] == property && method_desc["args"].size() == value.size():
            _props[property] = CalculatedProperty.new(self, property, value)
            return true
    push_error("Could not find function for  calculated property `%s`" % property)
    return false

func invoke_on(action_name: String, object: Object, sig: String):
    if action_name in _actions:
        _actions[action_name].invoke_on(object, sig)
    elif has_method(action_name):
        var __ = object.connect(sig, self, action_name)
    else:
        push_error("Invalid action `%s` bound to signal" % action_name)

func conn(target: Object, sig: String, method: String, binds: Array = [], flags: int = 0):
    if target.connect(sig, self, method, binds, flags) != OK:
        push_error("Failed to connect to signal '%s'" % sig)
        assert(false)



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
            return
    push_error("Failed to forward signal `%s`!" % sig)
            
func action(method: String) -> Action:
    return Action.new(self, method)

static func merge(a: Dictionary, b: Dictionary):
    Dict.merge(a, b)


class ViewModelBaseBuilderExt:
    var _vm
    var _s

    func _init(s, vm):
        _s = s
        _vm = vm

    func to(variant):
        _vm._active[_s] = variant
        return _vm

class ViewModelBaseBuilder:
    var _props: Dictionary = {}
    var _actions: Dictionary = {}
    var _instance: ViewModelBase

    var _active = null

    func props(): 
        _active = _props
        return self
    
    func actions():
        _active = _actions
        return self

    func from_dict(dict: Dictionary):
        print("hello")
        Dict.merge(_active, dict)
        return self

    func _get(property: String):
        return ViewModelBaseBuilderExt.new(property, self)

    func _init(instance):
        _instance = instance

    func init(args: Array = []):
        _instance.actually_init(_props, _actions, args)

static func builder(script):
    return ViewModelBaseBuilder.new(script)
