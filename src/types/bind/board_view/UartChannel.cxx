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

#include <algorithm>
#include <array>
#include "UartChannel.hxx"

using namespace godot;

void UartChannel::_register_methods() {
    register_method("write", &UartChannel::write);
    register_method("read", &UartChannel::read);
}

Ref<UartChannel> UartChannel::FromNative(smce::VirtualUart vu) {
    auto ret = make_ref<UartChannel>();
    ret->m_uart = vu;
    const auto max_write = vu.rx().max_size();
    ret->write_buf.reserve(max_write > 1024 ? max_write : 1024);
    ret->read_buf = std::vector<char>(vu.tx().max_size() + 1);
    return ret;
}

void UartChannel::poll() {
    if (!write_buf.empty()) {
        const auto written = m_uart.rx().write(write_buf);
        write_buf.erase(write_buf.begin(), write_buf.begin() + written);
    }

    size_t available;
    do {
        auto test = std::array<char, 16>{};
        available = m_uart.tx().read(test);
        if (available > 0) {
            std::replace_if(
                test.begin(), test.begin() + static_cast<ptrdiff_t>(available),
                [](const auto& letter) { return letter == '\0' || letter == '\r'; }, '\t');
            test[available] = '\0';

            gread_buf += static_cast<const char*>(read_buf.data());
        }
    } while (available != 0);
}

void UartChannel::write(String buf) {
    const auto ascii_buf = buf.ascii();
    std::copy_n(ascii_buf.get_data(), ascii_buf.length(), std::back_inserter(write_buf));

    poll();
}

String UartChannel::read() {
    poll();

    auto ret = gread_buf;
    gread_buf = "";
    return ret;
}