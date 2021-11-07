#
#  SketchBuilder.gd
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

class_name SketchBuilder

class SharedLog:
    var reader = null
    var buf: String = ""
    func _init(a):
        reader = a

class Token:
    var _shared_log: SharedLog
    var _log_head: int = 0
    var _future

    func _init(fut, lo):
        _shared_log = lo
        _future = fut

    func read_log() -> String:
        var read = _shared_log.reader.read()

        if read != null:
            _shared_log.buf += read

        var ret := _shared_log.buf.substr(_log_head)

        _log_head = _shared_log.buf.length()

        return ret

    func future():
        return _future

var _resource_dir: String

var ongoing = {}

func _init(resource_dir: String):
    _resource_dir = resource_dir

func queue_build(sketch) -> Token:
    if !ongoing.has(sketch):
        var tc = Toolchain.new()
        var res = tc.init(_resource_dir)
        assert(res.is_ok(), res)
        var reader = tc.log_reader()
        var future = Async.run(tc, "compile", [sketch])
        ongoing[sketch] = [future, SharedLog.new(reader)]
        future.connect("completed", self, "_on_compile_complete", [sketch])
    var x = ongoing[sketch]
    return Token.new(x[0], x[1])

func cancel_build(token: Token) -> bool:
    # TODO
    return true

func _on_compile_complete(sk):
    ongoing.erase(sk)
