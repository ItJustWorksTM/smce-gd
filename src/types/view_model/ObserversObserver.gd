#
#  ObserversObserver.gd
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

class_name ObserversObserver
    
signal changed(value)

var _deps: Array = []

func get_value() -> Array:
    var ret := []
    for dep in _deps:
        ret.append(dep.get_value())
    return ret

func _init(deps):
    for dep in deps:
        var obsv: Observable = Observable.from(dep)
        _deps.append(obsv)
        obsv.bind_change(self, "_on_change", [], CONNECT_REFERENCE_COUNTED)

func _on_change(__): emit_signal("changed", get_value())
