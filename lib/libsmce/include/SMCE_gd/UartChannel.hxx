
#ifndef GODOT_SMCE_UARTCHANNEL_HXX
#define GODOT_SMCE_UARTCHANNEL_HXX

#include <vector>
#include "SMCE_gd/BoardConfig.hxx"
#include "SMCE_gd/BoardView.hxx"
#include "SMCE_gd/gd_class.hxx"
#include "godot_cpp/godot.hpp"

using namespace godot;

class UartChannel : public GdRef<"UartChannel", UartChannel> {
    smce::VirtualUart m_uart = smce::BoardView{}.uart_channels[0];

    String gread_buf;
    std::vector<char> read_buf{};
    std::vector<char> write_buf{};

    Ref<BoardConfig::UartChannelConfig> m_info;

  public:
    static void _bind_methods();

    static Ref<UartChannel> from_native(Ref<BoardConfig::UartChannelConfig> info, smce::VirtualUart vu);

    void poll();

    void write(String buf);

    String read();

    Ref<BoardConfig::UartChannelConfig> info();
};

#endif // GODOT_SMCE_UARTSLURPER_HXX