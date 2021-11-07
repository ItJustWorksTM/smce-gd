#
#  Observable.gd
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

#
#  A value wrapper class that emits a signal when changed.
#
#  Note: change is only registered when the setter is called,
#  changes reference types such as Array and Dictionairy are not detected,
#  in that case call .emit_change() to trigger it manually.
#
class_name Observable

static func from(other):
    var Self = load("res://src/types/view_model/Observable.gd")
    if other is Reference && other.get_script() == Self:
        return other
    return Self.new(other)

signal changed(value)
signal _changed()

var value setget set_value, get_value

func get_value(): return value

func set_value(var _value):
    value = _value
    emit_change()


func _init(var _value = null):
    value = _value


# Convience function that will connect the change signal to specified method,
# and directly call given method with the current value.
func bind_change(var target: Object, var method: String, var binds: Array = [], flags: int = 0):
    var __ = connect("changed", target, method, binds, flags)
    binds.push_front(self.value) # push front to mimmic signal
    target.callv(method, binds)


# Convience function that will set a target property on change
# and directly set given property with the current value.
func bind_prop(var target: Object, var property: String):
    var __ = connect("_changed", target, "", [property])
    target.set(property, self.value)


# Manually trigger a change even if none occured.
# Useful for when dealing with reference types.
func emit_change():
    emit_signal("changed", value)

    # very hacky
    for connection in get_signal_connection_list("_changed"):
        connection["target"].set(connection["binds"][0], self.value)

func _to_string():
    return str(self.value)
