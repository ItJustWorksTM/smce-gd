/*
 *  Sketch.hxx
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

#ifndef GODOT_SMCE_SKETCH_HXX
#define GODOT_SMCE_SKETCH_HXX

#include "SMCE/Sketch.hpp"
#include "core/Godot.hpp"
#include "gen/Reference.hpp"
#include "types/Result.hxx"
#include "SketchConfig.hxx"

namespace godot {

class Toolchain;

// TODO: properly emit build_changed signal
class Sketch : public Reference {
    GODOT_CLASS(Sketch, Reference)

    friend Toolchain;

    smce::Sketch sketch{"", {}};

    String m_path;
    Ref<SketchConfig> m_conf = make_ref<SketchConfig>();

    smce::SketchConfig conf{};

  public:
    static void _register_methods();
    void _init() {}

    smce::Sketch& native() { return sketch; }

    void init(String src, Ref<SketchConfig> config);

    void set_path(String src);
    String get_path();

    void set_config(Ref<SketchConfig> config);
    Ref<SketchConfig> get_config();

    bool is_compiled();

    String _to_string();
};

} // namespace godot

#endif // GODOT_SMCE_SKETCH_HXX
