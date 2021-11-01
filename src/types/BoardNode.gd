#
#  BoardNode.gd
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

class_name BoardNode
extends Node

var _board = null
var _deps = []

class Dependent:
    extends Node
    func do_request(_builder: BoardBuilder): pass

func add_dep(node: Dependent):
    _deps.append(node)

func init():
    var builder = BoardBuilder.new()

    for dep in _deps:
        dep.do_request(builder)

    var res = builder.create()

    if res.is_ok():
        for dep in _deps:
            add_child(dep)
    
    _board = res.get_value()
    print(_board.get_status())
    return res

func stop():
    for dep in _deps:
        remove_child(dep)
    return _board.stop()

func start(sketch): return _board.start(sketch)
func suspend(): return _board.suspend()
func resume(): return _board.resume()
func status(): return _board.get_status()
func get_view(): return _board.get_view()
func is_active(): return _board.is_active()

func _process(__):
    if _board != null && _board.is_active():
        var _res = _board.poll()
        if _res.is_err():
            stop()
        # what do we do???
