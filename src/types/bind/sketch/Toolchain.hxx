/*
 *  Toolchain.hxx
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

#ifndef GODOT_SMCE_TOOLCHAIN_HXX
#define GODOT_SMCE_TOOLCHAIN_HXX

#include <memory>
#include <optional>
#include <types/Result.hxx>
#include "SMCE/Toolchain.hpp"
#include "core/Godot.hpp"
#include "types/bind/sketch/Sketch.hxx"

namespace godot {

class ToolchainLogReader : public Reference {
    GODOT_CLASS(ToolchainLogReader, Reference);

  public:
    std::shared_ptr<smce::Toolchain> tc;

    static void _register_methods();
    void _init() {}

    Variant read();
};

class Toolchain : public Reference {
    GODOT_CLASS(Toolchain, Reference)

    std::shared_ptr<smce::Toolchain> tc;

    Ref<ToolchainLogReader> reader;

  public:
    static void _register_methods();

    void _init() {}

    Ref<Result> init(String resource_dir);

    Ref<ToolchainLogReader> log_reader() { return reader; }

    bool is_initialized() { return (bool)tc; }

    Ref<Result> compile(Ref<Sketch> sketch);
};

} // namespace godot

#endif // GODOT_SMCE_TOOLCHAIN_HXX
