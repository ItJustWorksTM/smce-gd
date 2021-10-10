/*
 *  SketchConfig.cxx
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

#include "SketchConfig.hxx"

#include <tuple>
#include "types/bind/board/BoardDeviceSpec.hxx"
#include "util/Extensions.hxx"
using namespace godot;

#define STR(s) #s

void SketchConfig::_register_methods() {
#define P(f, d) std::tuple{STR(f), &SketchConfig::f, d}
    register_props(P(extra_board_uris, Array{}), P(legacy_preproc_libs, Array{}), P(fqbn, String{}),
                   P(plugins, Array{}), P(genbind_devices, Array{}));
#undef P
}

smce::SketchConfig SketchConfig::to_native() {
    return smce::SketchConfig{
        .fqbn = std_str(fqbn),
        .extra_board_uris = std_str_vec(extra_board_uris),
        .legacy_preproc_libs =
            [&] {
                auto r = std_str_vec(legacy_preproc_libs);
                auto n = std::vector<smce::SketchConfig::ArduinoLibrary>{};
                std::transform(r.begin(), r.end(), std::back_inserter(n), [](auto name) {
                    return smce::SketchConfig::ArduinoLibrary{.name = name, .version = {}};
                });
                return n;
            }(),
        .plugins =
            [&] {
                auto r = std::vector<smce::PluginManifest>{};

                for (size_t i = 0; i < plugins.size(); ++i) {
                    // likely to crash
                    r.push_back(static_cast<Ref<SketchConfig::PluginManifest>>(plugins[i])->to_native());
                }

                return r;
            }(),
        .genbind_devices =
            [&] {
                auto r = std::vector<std::reference_wrapper<const smce::BoardDeviceSpecification>>{};

                for (size_t i = 0; i < genbind_devices.size(); ++i) {
                    auto& t = static_cast<Ref<BoardDeviceSpec>>(genbind_devices[i])->to_native();
                    r.push_back(std::cref(t));
                }

                return r;
            }()};
}

void SketchConfig::PluginManifest::_register_methods() {
#define P(f, d) std::tuple{STR(f), &SketchConfig::PluginManifest::f, d}
    register_props(P(name, String{}), P(version, String{}), P(depends, Array{}), P(needs_devices, Array{}),
                   P(uri, String{}), P(patch_uri, String{}), P(defaults, 0), P(incdirs, Array{}),
                   P(sources, Array{}), P(linkdirs, Array{}), P(linklibs, Array{}), P(development, false));
#undef P
}

smce::PluginManifest SketchConfig::PluginManifest::to_native() {
    return smce::PluginManifest{.name = std_str(name),
                                .version = std_str(version),
                                .depends = std_str_vec(depends),
                                .needs_devices = std_str_vec(needs_devices),
                                .uri = std_str(uri),
                                .patch_uri = std_str(patch_uri),
                                .defaults = static_cast<smce::PluginManifest::Defaults>(defaults),
                                .incdirs = std_str_vec(incdirs),
                                .sources = std_str_vec(sources),
                                .linkdirs = std_str_vec(linkdirs),
                                .linklibs = std_str_vec(linklibs),
                                .development = development};
}