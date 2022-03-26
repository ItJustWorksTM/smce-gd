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

Ref<BoardView> BoardView::from_native(Ref<BoardConfig> board_config, smce::BoardView bv) {
    auto gbv = make_ref<This>();

    gbv->valid = true;
    gbv->view = bv;

    for (int i = 0; i < board_config->gpio_drivers.size(); ++i) {
        auto info = static_cast<Ref<BoardConfig::GpioDriverConfig>>(board_config->gpio_drivers[i]);
        gbv->pins[info->pin] = GpioPin::from_native(info, bv.pins[i]);
    }

    for (int i = 0; i < board_config->uart_channels.size(); ++i) {
        auto info = static_cast<Ref<BoardConfig::UartChannelConfig>>(board_config->uart_channels[i]);
        gbv->uart_channels.append(UartChannel::from_native(info, bv.uart_channels[i]));
    }

    for (int i = 0; i < board_config->frame_buffers.size(); ++i) {
        auto info = static_cast<Ref<BoardConfig::FrameBufferConfig>>(board_config->frame_buffers[i]);
        gbv->frame_buffers[info->key] = FrameBuffer::from_native(info, bv.frame_buffers[i]);
    }

    for (int i = 0; i < board_config->board_devices.size(); ++i) {
        // auto info = static_cast<Ref<BoardConfig::BoardDeviceConfig>>(board_config->board_devices[i]);
        // if (info.is_null()) {
        //     continue;
        // }

        // auto key = String{info->spec->to_native().name.data()};

        // if (gbv->board_devices.has(key))
        //     continue;

        // auto devices = Array{};

        // for (size_t i = 0; i < info->amount + 1; ++i) {
        //     devices.push_back(DynamicBoardDevice::create(info->spec, bv));
        // }

        // gbv->board_devices[key] = devices;
    }

    return gbv;
}

smce::BoardView BoardView::native() { return view; }

void BoardView::poll() {
    for (int i = 0; i < uart_channels.size(); ++i) {
        static_cast<Ref<UartChannel>>(uart_channels[i])->poll();
    }
}
