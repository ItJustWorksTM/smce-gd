#
#  Action.gd
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

class_name Action

var _obj: Object
var _method: String
var _extra: Array = []

func _init(obj, method, extra = []):
    _obj = obj
    _method = method
    _extra = extra

func invoke(args: Array = [], binds: Array = []) -> void:
    print(args + _extra + binds)
    _obj.callv(_method, args + _extra + binds)
    print("Action: [", _method, "], Args: ", args, " Binds: ", binds)

func invoke_on(obj: Object, sig: String, binds: Array = []):
    while is_instance_valid(obj):
        var args = yield(Yield.sig(obj, sig), "completed")
        if args == null: break
        invoke(args, binds)

func with(_binds: Array):
    var Self = load("res://src/types/view_model/action/Action.gd")
    return Self.new(self, "invoke", [_binds])
