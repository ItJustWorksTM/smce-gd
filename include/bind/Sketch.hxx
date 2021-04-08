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

namespace godot {

class Sketch : public Reference {
    GODOT_CLASS(Sketch, Reference)

    smce::Sketch sketch{"", {}};

  public:
    static void _register_methods();
    void _init() {}

    smce::Sketch& native() { return sketch; }

    // TODO: support SketchConfig
    // TOOD: remove home_dir§
    void init(String src, String home_dir);

    String get_source();
    bool is_compiled();
    String get_uuid();
};

} // namespace godot

#endif // GODOT_SMCE_SKETCH_HXX
