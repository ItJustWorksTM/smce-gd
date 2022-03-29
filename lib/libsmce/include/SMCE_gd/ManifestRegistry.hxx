
#ifndef SMCE_GD_MANIFESTREGISTRY_HXX
#define SMCE_GD_MANIFESTREGISTRY_HXX

#include "SMCE_gd/BoardDeviceSpecification.hxx"
#include "SMCE_gd/PluginManifest.hxx"
#include "SMCE_gd/gd_class.hxx"
#include "SMCE_gd/utility.hxx"
#include "godot_cpp/variant/dictionary.hpp"

using namespace godot;

class ManifestRegistry : public GdRef<"ManifestRegistry", ManifestRegistry> {

    Dictionary plugins;
    Dictionary board_devices;

  public:
    static void _bind_methods() {
        bind_method("add_board_device", &This::add_board_device);
        bind_method("add_plugin", &This::add_plugin);
    }

    Ref<PluginManifest> get_plugin(String name) const { return plugins.get(name, Ref<PluginManifest>{}); }

    void add_plugin(Ref<PluginManifest> plugin) { plugins[plugin->plugin_name] = plugin; }

    void add_board_device(Ref<BoardDeviceSpecification> spec) { board_devices[spec->name] = spec; }
    Ref<BoardDeviceSpecification> get_board_device(String name) const {
        return board_devices.get(name, Ref<BoardDeviceSpecification>{});
    }
};

#endif