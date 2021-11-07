#
#  UartPuller.gd
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

class_name UartPuller
extends BoardNode.Dependent

signal read()

var _uart_channel

func do_request(builder: BoardBuilder):
    var uart: Array = yield(builder.request([UartChannelConfig.new()]), "completed")

    if uart.empty():
        return
    
    _uart_channel = uart[0]

func _process(__):
    var read = _uart_channel.read()
    if read != null:
        emit_signal("read", read)

func write(_text):
    pass
