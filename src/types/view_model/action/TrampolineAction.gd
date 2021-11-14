#
#  TrampolineAction.gd
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

class_name TrampolineAction
extends Action

var _owner: Object
var _callback: String

func _init(obj: Object, method: String, owner: Object, callback: String).(obj, method):
    _owner = owner
    _callback = callback

func invoke(args: Array = []) -> void:
    var res = _obj.callv(_method, args)
    _owner.call(_callback, res)
    print("Action: [", _method, "], Args: ", args, ", Result: [", res, "]")
