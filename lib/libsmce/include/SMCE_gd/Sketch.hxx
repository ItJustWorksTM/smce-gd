#ifndef SMCE_GD_SKETCH_HXX
#define SMCE_GD_SKETCH_HXX

#include <algorithm>
#include <memory>
#include <ranges>
#include <span>
#include <unordered_set>
#include "SMCE/Sketch.hpp"
#include "SMCE_gd/BoardDeviceSpecification.hxx"
#include "SMCE_gd/ManifestRegistry.hxx"
#include "SMCE_gd/gd_class.hxx"
#include "SMCE_gd/utility.hxx"
#include "godot_cpp/variant/utility_functions.hpp"

using namespace godot;

struct SketchConfig : public GdRef<"SketchConfig", SketchConfig> {
  public:
    static void _bind_methods() {
        bind_prop_rw<"extra_board_uris", Variant::Type::PACKED_STRING_ARRAY, &This::extra_board_uris>();
        bind_prop_rw<"legacy_preproc_libs", Variant::Type::PACKED_STRING_ARRAY, &This::legacy_preproc_libs>();
        bind_prop_rw<"plugins", Variant::Type::PACKED_STRING_ARRAY, &This::plugins>();
    }

    PackedStringArray legacy_preproc_libs;
    PackedStringArray extra_board_uris;
    PackedStringArray plugins;

    smce::SketchConfig resolve_config(Ref<ManifestRegistry> registry) {
        auto config = smce::SketchConfig{
            .fqbn = "FQBN",
        };

        for (const auto& lib : as_span(legacy_preproc_libs))
            config.legacy_preproc_libs.emplace_back(smce::SketchConfig::ArduinoLibrary{.name = to_utf8(lib)});

        for (const auto& uris : as_span(extra_board_uris))
            config.extra_board_uris.emplace_back(to_utf8(uris));

        auto exist_devices = std::unordered_set<std::string>{};

        for (const auto& name : as_span(plugins))
            if (auto plugin = registry->get_plugin(name); plugin.is_valid()) {
                auto native_plugin = plugin->to_native();

                for (const auto& dev_name : as_span(plugin->needs_devices))
                    if (auto device = registry->get_board_device(dev_name); device.is_valid()) {
                        auto native_device = device->to_native();
                        auto name = std::string{native_device.name()};
                        if (!exist_devices.contains(name)) {
                            exist_devices.insert(name);
                            config.genbind_devices.emplace_back(std::move(native_device));
                        }
                    } else
                        UtilityFunctions::printerr("Plugin required non existing board device.");

                config.plugins.emplace_back(std::move(native_plugin));
            }

        return config;
    }
};

class Sketch : public GdRef<"Sketch", Sketch> {
    std::unique_ptr<smce::Sketch> inner{};

    String source;
    Ref<SketchConfig> config;

  public:
    Sketch() {
        config = Ref<SketchConfig>{};
        config.instantiate();
    }

    String get_source() { return source; }
    void set_source(String new_source) {
        source = new_source;
        reset();
    }

    Ref<SketchConfig> get_config() { return config; }
    void set_config(Ref<SketchConfig> new_config) {
        config = new_config;
        reset();
    }

    bool get_compiled() { return inner && inner->is_compiled(); }
    void set_compiled(bool compiled) {
        if (get_compiled() && !compiled)
            reset();
    }

    smce::Sketch& as_native() { return *inner; }

    void resolve_config(Ref<ManifestRegistry> registry) {
        auto native_config = config->resolve_config(registry);
        inner = std::make_unique<smce::Sketch>(as_view(source), native_config);
    }

    void reset() {
        UtilityFunctions::print("reset was called");
        inner.reset();
    }

    static void _bind_methods() {
        bind_method("get_source", &This::get_source);
        bind_method("set_source", &This::set_source);
        bind_method("get_config", &This::get_config);
        bind_method("set_config", &This::set_config);
        bind_method("get_compiled", &This::get_compiled);
        bind_method("set_compiled", &This::set_compiled);
        bind_prop("source", Variant::Type::STRING, "get_source", "set_source");
        bind_prop("config", Variant::Type::OBJECT, "get_config", "set_config");
        bind_prop("compiled", Variant::Type::BOOL, "get_compiled", "set_compiled");
    }
};

#endif