#ifndef SMCE_GD_SKETCH_HXX
#define SMCE_GD_SKETCH_HXX

#include <algorithm>
#include <memory>
#include "SMCE/Sketch.hpp"
#include "SMCE_gd/BoardDeviceSpecification.hxx"
#include "SMCE_gd/ManifestRegistry.hxx"
#include "SMCE_gd/gd_class.hxx"
#include "SMCE_gd/utility.hxx"

using namespace godot;

struct SketchConfig : public GdRef<"SketchConfig", SketchConfig> {
  public:
    static void _bind_methods() {
        bind_prop_rw<"extra_board_uris", Variant::Type::PACKED_STRING_ARRAY, &This::extra_board_uris>();
        bind_prop_rw<"legacy_preproc_libs", Variant::Type::PACKED_STRING_ARRAY, &This::legacy_preproc_libs>();
        bind_prop_rw<"plugins", Variant::Type::PACKED_STRING_ARRAY, &This::plugins>();
        bind_prop_rw<"board_devices", Variant::Type::PACKED_STRING_ARRAY, &This::board_devices>();
    }

    PackedStringArray legacy_preproc_libs;
    PackedStringArray extra_board_uris;
    PackedStringArray plugins;
    PackedStringArray board_devices;

    smce::SketchConfig resolve_config(Ref<ManifestRegistry> registry) {
        auto config = smce::SketchConfig{
            .fqbn = "FQBN",
        };

        const auto insert_transform = [](auto& in, auto& out, auto fun) {
            if (in.size())
                std::transform(in.ptr(), in.ptr() + in.size(), std::back_inserter(out), fun);
        };

        insert_transform(legacy_preproc_libs, config.legacy_preproc_libs, [&](const auto& str) {
            return smce::SketchConfig::ArduinoLibrary{.name = to_utf8(str)};
        });
        insert_transform(extra_board_uris, config.extra_board_uris, to_utf8);

        insert_transform(plugins, config.plugins,
                         [&](const auto& str) { return registry->get_plugin(str)->to_native(); });

        insert_transform(board_devices, config.genbind_devices,
                         [&](const auto& str) { return registry->get_board_device(str)->to_native(); });

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