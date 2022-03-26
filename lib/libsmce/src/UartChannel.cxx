
#include <algorithm>
#include <array>
#include "SMCE_gd/UartChannel.hxx"

using namespace godot;

void UartChannel::_bind_methods() {
    bind_method("write", &This::write);
    bind_method("read", &This::read);
    bind_method("info", &This::info);
}

Ref<UartChannel> UartChannel::from_native(Ref<BoardConfig::UartChannelConfig> info, smce::VirtualUart vu) {
    auto ret = make_ref<This>();
    ret->m_uart = vu;
    const auto max_write = vu.rx().max_size();
    ret->write_buf.reserve(max_write > 1024 ? max_write : 1024);
    ret->read_buf = std::vector<char>(vu.tx().max_size() + 1);
    ret->m_info = info;
    return ret;
}

void UartChannel::poll() {
    if (!write_buf.empty()) {
        const auto written = m_uart.rx().write(write_buf);
        write_buf.erase(write_buf.begin(), write_buf.begin() + written);
    }

    size_t available;
    do {
        available = m_uart.tx().read(read_buf);
        if (available > 0) {
            std::replace_if(
                read_buf.begin(), read_buf.begin() + static_cast<ptrdiff_t>(available),
                [](const auto& letter) { return letter == '\0' || letter == '\r'; }, '\t');
            read_buf[available] = '\0';

            gread_buf = gread_buf + String(static_cast<const char*>(read_buf.data()));
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

Ref<BoardConfig::UartChannelConfig> UartChannel::info() { return m_info; }