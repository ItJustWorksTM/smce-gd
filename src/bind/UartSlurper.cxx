/*
 *  UartSlurper.cxx
 *  Copyright 2021 ItJustWorksTM
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

#include "bind/UartSlurper.hxx"
#include <ranges>

using namespace godot;

void UartSlurper::_register_methods() {
    register_method("_physics_process", &UartSlurper::_physics_process);
    register_method("write", &UartSlurper::write);
    register_method("channels", &UartSlurper::channels);
    register_signal<UartSlurper>("uart");
}

void UartSlurper::_init() { set_physics_process(false); }

void UartSlurper::_physics_process(float) {
    size_t i = 0;
    for (auto &[available, read_buf, write_buf] : bufs) {


        auto written = view.uart_channels[i].rx().write(write_buf);
        write_buf.erase(write_buf.begin(), write_buf.begin() + written);

        available = view.uart_channels[i].tx().read({read_buf.begin(), read_buf.end() - 1});
        if (available > 0) {
            std::replace_if(read_buf.begin(), read_buf.begin() + available,
                            [](const auto &letter) { return letter == '\0'; }, '\r'); // godot seems to ignore \r
            read_buf[available] = '\0';
            emit_signal("uart", 0, String(static_cast<const char *>(read_buf.data())));
        }

        ++i;
    }
}

void UartSlurper::setup_bufs(smce::BoardView new_view) {
    view = new_view;

    if (!view.valid())
        return;

    for (size_t i = 0; i < view.uart_channels.size(); ++i) {
        const auto max_write = view.uart_channels[i].rx().max_size();
        auto write_buf = std::vector<char>{};
        write_buf.reserve(max_write > 1024 ? max_write : 1024);
        bufs.push_back({0,std::vector<char>(view.uart_channels[i].tx().max_size() + 1), std::move(write_buf)});
    }

    set_physics_process(true);
}

bool UartSlurper::write(int channel, String msg) {
    if (!view.valid() || !view.uart_channels[channel].rx().exists())
        return false;

    const auto str = msg.ascii();
    std::copy_n(str.get_data(), str.length(), std::back_inserter( bufs[channel].write_buf));

    return true;
}

int UartSlurper::channels() {
    return view.valid() ? view.uart_channels.size() : -1;
}

