#
#  BoardLogic.gd
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

class_name BoardLogic
extends BoardLogicBase

func _init(sb, sk).(sb, sk):
    # If the sketch is already compiled then we can setup the board
    if _sketch.is_compiled():
        setup()

func setup():
    # TODO: reset state?
    return .setup()

func _setup_hook(builder):
    var uart = Yield.save_value(builder.request([UartChannelConfig.new()]))

    # Setup actual attachments

    yield()

    uart = uart.value()[0]

    uart.write("hello world!")


func start():
    var res = .start()

    if res.is_ok():
        # enable vehicle and shit?
        pass

    return res

func _terminate_hook(exit_code):
    if exit_code != 0:
        print("We crashed with exit code: ", exit_code)
    
    # Here we have to power down all nodes that were borrowing our shit

func _process(__):
    if _compile_token != null:
        print(_compile_token.read_log())
