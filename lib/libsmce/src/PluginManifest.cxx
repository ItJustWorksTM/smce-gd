
#include <PluginManifest.hpp>
#include "SMCE_gd/PluginManifest.hxx"

void PluginManifest::_bind_methods() {
    {
        bind_enum("Defaults", std::array{
                                  "DEFAULT_ARDUINO",
                                  "DEFAULT_SINGLE_DIR",
                                  "DEFAULT_C",
                                  "DEFAULT_NONE",
                                  "DEFAULT_CMAKE",
                              });

        using Type = Variant::Type;

        bind_prop_rw<"plugin_name", Variant::Type::STRING, &This::plugin_name>();
        bind_prop_rw<"depends", Type::PACKED_STRING_ARRAY, &This::depends>();
        bind_prop_rw<"needs_devices", Type::PACKED_STRING_ARRAY, &This::needs_devices>();
        bind_prop_rw<"uri", Type::STRING, &This::uri>();
        bind_prop_rw<"defaults", Type::INT, &This::defaults>();
        bind_prop_rw<"patch_uri", Type::STRING, &This::patch_uri>();
        bind_prop_rw<"incdirs", Type::PACKED_STRING_ARRAY, &This::incdirs>();
        bind_prop_rw<"sources", Type::PACKED_STRING_ARRAY, &This::sources>();
        bind_prop_rw<"linkdirs", Type::PACKED_STRING_ARRAY, &This::linkdirs>();
        bind_prop_rw<"linklibs", Type::PACKED_STRING_ARRAY, &This::linklibs>();
        bind_prop_rw<"development", Type::BOOL, &This::development>();
    }
}

smce::PluginManifest PluginManifest::to_native() {
    auto ret = smce::PluginManifest{.name = to_utf8(plugin_name),
                                    .version = "1.0.0",
                                    .uri = to_utf8(uri),
                                    .patch_uri = to_utf8(patch_uri),
                                    .defaults = static_cast<smce::PluginManifest::Defaults>(defaults),
                                    .development = development};

    const auto insert_transform = [](const auto& in, auto& out) {
        for (const auto& str : as_span(in))
            out.emplace_back(to_utf8(str));
    };

    insert_transform(depends, ret.depends);
    insert_transform(needs_devices, ret.needs_devices);
    insert_transform(incdirs, ret.incdirs);
    insert_transform(sources, ret.sources);
    insert_transform(linkdirs, ret.linkdirs);
    insert_transform(linklibs, ret.linklibs);

    return ret;
}