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

class_name Observable2

signal value_changed()

var _object
var _property

func _init(object: Object, property: String):
    _object = object
    _property = property
    _object.connect(property + "_changed", self, "_on_change")

func get_value():
    return _object.get(_property)

func _on_change(val): emit_signal("value_changed", val)
