#
#  BoardBuilder.gd
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


class_name BoardBuilder

var _requ := BoardConfig.new()

signal _consume(view)

func find(arr, a):
    for exi in arr:
        if Reflect.value_compare(exi, a):
            return exi
    return null

func request(arr):

    var getter := []
    for a in arr:

        match a.get_script():
            UartChannelConfig:
                _requ.uart_channels.append(a)
                getter.append([UartChannelConfig, _requ.uart_channels.size() - 1])
            BoardDeviceConfig:
                var bd = find(_requ.board_devices, a)
                if bd == null:
                    _requ.board_devices.append(a)
                    bd = a
                else:
                    bd.amount += 1 # TODO: honor amount on device config? or just use device spec directly
                getter.append([BoardDeviceConfig, bd.spec.name, bd.amount])

            GpioDriverConfig:
                if find(_requ.gpio_drivers, a) == null:
                    _requ.gpio_drivers.append(a)
                    getter.append([GpioDriverConfig, a.pin])

            FrameBufferConfig:
                if find(_requ.gpio_drivers, a) == null:
                    _requ.frame_buffers.append(a)
                    getter.append([FrameBufferConfig, a.key])

            SecureDigitalStorage:
                if find(_requ.sd_cards, a) == null:
                    _requ.sd_cards.append(a)
                    getter.append([FrameBufferConfig, a.cspin])

            _: assert(false)

    var board_view = yield(self, "_consume")

    var ret := []
    for g in getter:
        match g[0]:
            UartChannelConfig:
                ret.append(board_view.uart_channels[g[1]])
            BoardDeviceConfig:
                print(board_view.board_devices[g[1]])
                ret.append(board_view.board_devices[g[1]][g[2]])
            GpioDriverConfig:
                ret.append(board_view.pins[g[1]])
            FrameBufferConfig:
                ret.append(board_view.frame_buffers[g[1]])
            SecureDigitalStorage:
                ret.append(board_view.sd_cards[g[1]])
            _: assert(false)
    print(ret)

    if ret.size() != arr.size():
        push_error("Overlapping requiremetns!")
        return null
    
    return ret

func consume():
    var board = Board.new()
    var init_res = board.init(_requ)

    emit_signal("_consume", board.get_view())

    print(init_res)
    
    return Result.new().err_from(init_res, board)

