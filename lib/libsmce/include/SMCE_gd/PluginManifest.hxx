#ifndef SMCE_GD_PLUGINMANIFEST_HXX
#define SMCE_GD_PLUGINMANIFEST_HXX

#include "SMCE/PluginManifest.hpp"
#include "SMCE_gd/gd_class.hxx"
#include "SMCE_gd/utility.hxx"
#include "godot_cpp/classes/ref_counted.hpp"
#include "godot_cpp/core/class_db.hpp"
#include "godot_cpp/core/defs.hpp"
#include "godot_cpp/godot.hpp"
#include "godot_cpp/variant/utility_functions.hpp"

using namespace godot;

struct PluginManifest : public GdRef<"PluginManifest", PluginManifest> {
  public:
    static void _bind_methods();
    String plugin_name;
    String version;
    PackedStringArray depends;
    PackedStringArray needs_devices;
    String uri;
    String patch_uri;
    smce::PluginManifest::Defaults defaults;
    PackedStringArray incdirs;
    PackedStringArray sources;
    PackedStringArray linkdirs;
    PackedStringArray linklibs;
    bool development = false;

    smce::PluginManifest to_native() {
        auto ret = smce::PluginManifest{.name = to_utf8(plugin_name),
                                        .version = to_utf8(version),
                                        .uri = to_utf8(uri),
                                        .patch_uri = to_utf8(patch_uri),
                                        .development = development};

        const auto insert_transform = [](auto& in, auto& out) {
            if (in.size())
                std::transform(in.ptr(), in.ptr() + in.size(), std::back_inserter(out), to_utf8);
        };

        insert_transform(depends, ret.depends);
        insert_transform(needs_devices, ret.needs_devices);
        insert_transform(incdirs, ret.incdirs);
        insert_transform(sources, ret.sources);
        insert_transform(linkdirs, ret.linkdirs);
        insert_transform(linklibs, ret.linklibs);

        return ret;
    }
};

#endif