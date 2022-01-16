/*
 *  Toolchain.hxx
 *  Copyright 2022 ItJustWorksTM
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

#ifndef GODOT_SMCE_TOOLCHAIN_HXX
#define GODOT_SMCE_TOOLCHAIN_HXX

#include <optional>
#include "SMCE/Toolchain.hpp"
#include "bind/Sketch.hxx"
#include "core/Godot.hpp"
#include "gd/AnyTask.hxx"
#include "gd/GDResult.hxx"
#include "gen/Node.hpp"

namespace godot {

class Toolchain : public Node {
    GODOT_CLASS(Toolchain, Node)

    std::optional<smce::Toolchain> tc{""};

    bool building = false;
    bool queued_free = false;

    String log;

  public:
    static void _register_methods();
    void _init();

    smce::Toolchain& native() { return *tc; }

    Ref<GDResult> init(String resource_dir);
    void _physics_process();

    String resource_dir();
    String cmake_path();
    Ref<GDResult> check_suitable_environment();
    String get_log();

    bool is_building() { return building; }

    bool compile(Ref<Sketch> sketch);

    void set_free();
};

} // namespace godot

#endif // GODOT_SMCE_TOOLCHAIN_HXX
