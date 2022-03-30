
#include <iostream>
#include "godot_cpp/classes/ref_counted.hpp"
#include "godot_cpp/core/class_db.hpp"
#include "godot_cpp/core/defs.hpp"
#include "godot_cpp/godot.hpp"
#include "godot_cpp/variant/utility_functions.hpp"

#include "SMCE_gd/Board.hxx"
#include "SMCE_gd/BoardConfig.hxx"
#include "SMCE_gd/BoardDevice.hxx"
#include "SMCE_gd/BoardDeviceSpecification.hxx"
#include "SMCE_gd/BoardView.hxx"
#include "SMCE_gd/FrameBuffer.hxx"
#include "SMCE_gd/GpioPin.hxx"
#include "SMCE_gd/ManifestRegistry.hxx"
#include "SMCE_gd/PluginManifest.hxx"
#include "SMCE_gd/Sketch.hxx"
#include "SMCE_gd/Toolchain.hxx"
#include "SMCE_gd/UartChannel.hxx"

using namespace godot;

template <class... Ts> void register_types() { (ClassDB::register_class<Ts>(), ...); }

// TODO: make this standalone function so that this can be used as a library elsewhere
extern "C" {
GDNativeBool GDN_EXPORT example_library_init(const GDNativeInterface* p_interface,
                                             const GDNativeExtensionClassLibraryPtr p_library,
                                             GDNativeInitialization* r_initialization) {
    godot::GDExtensionBinding::InitObject init_obj(p_interface, p_library, r_initialization);

    init_obj.register_scene_initializer(
        register_types<Result, ManifestRegistry, BoardDeviceSpecification, PluginManifest, Sketch,
                       SketchConfig, BoardConfig, BoardConfig::BoardDeviceConfig,
                       BoardConfig::GpioDriverConfig, BoardConfig::FrameBufferConfig,
                       BoardConfig::SecureDigitalStorageConfig, BoardConfig::UartChannelConfig, Toolchain,
                       ToolchainLogReader, Board, BoardLogReader, BoardView, GpioPin, FrameBuffer,
                       UartChannel, BoardDevice, VirtualDeviceMutex>);

    init_obj.register_scene_terminator(+[] {});

    return init_obj.init();
}
}