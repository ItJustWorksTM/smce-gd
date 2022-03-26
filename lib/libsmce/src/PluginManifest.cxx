
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
        bind_prop_rw<"version", Type::STRING, &This::version>();
        bind_prop_rw<"depends", Type::PACKED_STRING_ARRAY, &This::depends>();
        bind_prop_rw<"uri", Type::STRING, &This::uri>();
        bind_prop_rw<"patch_uri", Type::STRING, &This::patch_uri>();
        bind_prop_rw<"incdirs", Type::PACKED_STRING_ARRAY, &This::incdirs>();
        bind_prop_rw<"sources", Type::PACKED_STRING_ARRAY, &This::sources>();
        bind_prop_rw<"linkdirs", Type::PACKED_STRING_ARRAY, &This::linkdirs>();
        bind_prop_rw<"linklibs", Type::PACKED_STRING_ARRAY, &This::linklibs>();
        bind_prop_rw<"development", Type::BOOL, &This::development>();
    }
}