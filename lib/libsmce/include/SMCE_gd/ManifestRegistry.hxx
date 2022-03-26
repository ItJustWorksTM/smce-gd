
#ifndef SMCE_GD_MANIFESTREGISTRY_HXX
#define SMCE_GD_MANIFESTREGISTRY_HXX

#include "SMCE_gd/BoardDeviceSpecification.hxx"
#include "SMCE_gd/PluginManifest.hxx"
#include "SMCE_gd/gd_class.hxx"

using namespace godot;

class ManifestRegistry : public GdRef<"ManifestRegistry", ManifestRegistry> {

    std::unordered_map<std::string, Ref<PluginManifest>> plugins;
    std::unordered_map<std::string, Ref<BoardDeviceSpecification>> board_devices;

  public:
    static void _bind_methods() {}

    Ref<PluginManifest> get_plugin(String name) const { return plugins.at(to_utf8(name)); }
    void set_plugin(String name) {}

    void set_board_device(String name) {}
    Ref<BoardDeviceSpecification> get_board_device(String name) const {
        return board_devices.at(to_utf8(name));
    }
};

#endif