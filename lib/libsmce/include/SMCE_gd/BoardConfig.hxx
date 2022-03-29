#ifndef SMCE_GD_BOARDCONFIG_HXX
#define SMCE_GD_BOARDCONFIG_HXX

#include "SMCE/BoardConf.hpp"
#include "SMCE_gd/ManifestRegistry.hxx"
#include "SMCE_gd/gd_class.hxx"

using namespace godot;

struct BoardConfig : public GdRef<"BoardConfig", BoardConfig> {

    struct GpioDriverConfig : public GdRef<"GpioDriverConfig", GpioDriverConfig> {
        int pin = 0;
        bool read = true;
        bool write = true;

        static void _bind_methods();
        smce::BoardConfig::GpioDrivers to_native() const;
    };
    struct UartChannelConfig : public GdRef<"UartChannelConfig", UartChannelConfig> {
        int rx_pin_override; // negative = nullopt
        int tx_pin_override;
        int baud_rate = 9600;
        int rx_buffer_length = 64;
        int tx_buffer_length = 64;
        int flushing_threshold = 0;

        static void _bind_methods();
        smce::BoardConfig::UartChannel to_native() const;
    };

    struct SecureDigitalStorageConfig
        : public GdRef<"SecureDigitalStorageConfig", SecureDigitalStorageConfig> {
        int cspin = 0;   /// SPI Chip-Select pin; default one opened is 0
        String root_dir; /// Path to root directory

        static void _bind_methods();
        smce::BoardConfig::SecureDigitalStorage to_native() const;
    };

    struct FrameBufferConfig : public GdRef<"FrameBufferConfig", FrameBufferConfig> {
        int key;
        int direction;

        static void _bind_methods();
        smce::BoardConfig::FrameBuffer to_native() const;
    };

    struct BoardDeviceConfig : public GdRef<"BoardDeviceConfig", BoardDeviceConfig> {
        String device_name;
        String version;
        std::size_t count;

        static void _bind_methods();
        smce::BoardConfig::BoardDevice resolve_native(Ref<ManifestRegistry> registry) const;
    };

    PackedInt32Array pins;
    Array gpio_drivers;
    Array uart_channels;
    Array sd_cards;
    Array frame_buffers;
    Array board_devices;

    smce::BoardConfig resolve_native(Ref<ManifestRegistry> registry) const;

    static void _bind_methods();
};
#endif