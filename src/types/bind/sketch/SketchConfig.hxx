/*
 *  SketchConfig.hxx
 *  Copyright 2021 ItJustWorksTM
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

#ifndef GODOT_SMCE_SKETCHCONFIG_HXX
#define GODOT_SMCE_SKETCHCONFIG_HXX

#include "SMCE/PluginManifest.hpp"
#include "SMCE/SketchConf.hpp"
#include "core/Godot.hpp"
#include "gen/Reference.hpp"
#include "util/Extensions.hxx"

namespace godot {

struct SketchConfig : public GdRef<"SketchConfig", SketchConfig> {
    struct PluginManifest : public GdRef<"PluginManifest", PluginManifest> {
        String name;
        String version;
        Array /* String */ depends;
        Array /* String */ needs_devices;
        String uri;
        String patch_uri;
        int defaults;
        Array /* String */ incdirs;
        Array /* String */ sources;
        Array /* String */ linkdirs;
        Array /* String */ linklibs;
        bool development;

        static void _register_methods();

        smce::PluginManifest to_native();
    };

    Array extra_board_uris;

    // TODO: delete once smce also drops legacy support
    Array /* String */ legacy_preproc_libs;
    String fqbn = "deprecated";

    Array /* Ref<PluginManifest> */ plugins;

    // Cursed
    Array genbind_devices;

    static void _register_methods();

    smce::SketchConfig to_native();
};

} // namespace godot

#endif // GODOT_SMCE_SKETCHCONFIG_HXX
