#ifndef SMCE_GD_PLUGINMANIFEST_HXX
#define SMCE_GD_PLUGINMANIFEST_HXX

#include "SMCE/PluginManifest.hpp"
#include "SMCE_gd/gd_class.hxx"
#include "SMCE_gd/utility.hxx"
#include "godot_cpp/classes/ref_counted.hpp"
#include "godot_cpp/core/class_db.hpp"
#include "godot_cpp/core/defs.hpp"
#include "godot_cpp/godot.hpp"
#include "godot_cpp/variant/packed_string_array.hpp"
#include "godot_cpp/variant/utility_functions.hpp"

using namespace godot;

struct PluginManifest : public GdRef<"PluginManifest", PluginManifest> {
  public:
    String plugin_name;
    PackedStringArray depends;
    PackedStringArray needs_devices;
    String uri;
    String patch_uri;
    int defaults;
    PackedStringArray incdirs;
    PackedStringArray sources;
    PackedStringArray linkdirs;
    PackedStringArray linklibs;
    bool development = false;

    static void _bind_methods();

    smce::PluginManifest to_native();
};

#endif