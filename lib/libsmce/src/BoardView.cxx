#include <ranges>
#include <Board.hpp>
#include <BoardConf.hpp>
#include "SMCE_gd/BoardDevice.hxx"
#include "SMCE_gd/BoardView.hxx"
#include "SMCE_gd/FrameBuffer.hxx"
#include "SMCE_gd/GpioPin.hxx"
#include "SMCE_gd/UartChannel.hxx"

using namespace godot;

void BoardView::_bind_methods() {
    // register_signals<BoardView>("invalidated");
    bind_prop_rw<"pins", Variant::Type::DICTIONARY, &This::pins>();
    bind_prop_rw<"uart_channels", Variant::Type::ARRAY, &This::uart_channels>();
    bind_prop_rw<"frame_buffers", Variant::Type::DICTIONARY, &This::frame_buffers>();
    bind_prop_rw<"board_devices", Variant::Type::DICTIONARY, &This::board_devices>();

    bind_method("is_valid", &This::is_valid);
}

Ref<BoardView> BoardView::from_native(smce::BoardConfig board_config, smce::BoardView bv) {
    auto gbv = make_ref<This>();

    gbv->valid = true;
    gbv->view = bv;

    for (int i = 0; i < board_config.gpio_drivers.size(); ++i) {
        const auto id = board_config.gpio_drivers[i].pin_id;
        gbv->pins[id] = GpioPin::from_native(bv.pins[id]);
    }

    for (int i = 0; i < board_config.uart_channels.size(); ++i) {
        gbv->uart_channels.append(UartChannel::from_native(bv.uart_channels[i]));
    }

    for (int i = 0; i < board_config.frame_buffers.size(); ++i) {
        const auto key = board_config.frame_buffers[i].key;
        gbv->frame_buffers[key] = FrameBuffer::from_native(bv.frame_buffers[key]);
    }

    for (const auto& fml : board_config.board_devices) {

        auto devices = Array{};

        auto bdv = smce::BoardDeviceView{bv}[fml.spec.name()];

        for (std::size_t i = 0; i < bdv.size(); ++i) {
            devices.push_back(BoardDevice::from_native(bdv[i], fml.spec));
        }

        gbv->board_devices[String(std::string{fml.spec.name()}.c_str())] = devices;
    }

    return gbv;
}

smce::BoardView BoardView::native() { return view; }

void BoardView::poll() {
    for (int i = 0; i < uart_channels.size(); ++i) {
        static_cast<Ref<UartChannel>>(uart_channels[i])->poll();
    }
}
