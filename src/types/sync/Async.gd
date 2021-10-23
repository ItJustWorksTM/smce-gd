#
#  Async.gd
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

class_name Async

class _Async:
    var thread: Thread
    var lambda: FuncRef
    var promise

    func _init(obj, method, args):
        var __ = reference()
        thread = Thread.new()
        lambda = funcref(obj, method)
        promise = Promise.new()
        var res = thread.start(self, "_run", args)
        assert(res == OK)

    func _run(args):
        promise.set_value(lambda.call_funcv(args))
        call_deferred("_delete")

    func _delete():
        thread.wait_to_finish()
        var __ = unreference()

static func run(obj: Object, method: String, args: Array):
    return _Async.new(obj, method, args).promise.get_future()
