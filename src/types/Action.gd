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

func _init(obj, method):
    _obj = obj
    _method = method

func invoke(args: Array = []) -> void:
    _obj.callv(_method, args)
    print("Action: [", _method, "], Args: ", args)

func invoke_on(obj: Object, sig: String):
    var res = obj.connect(sig, self, "invoke") == OK
    assert(res)

