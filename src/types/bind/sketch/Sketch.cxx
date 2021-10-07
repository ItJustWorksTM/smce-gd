/*
 *  Sketch.cxx
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

#include "util/Extensions.hxx"
#include "Sketch.hxx"

using namespace godot;

#define STR(s) #s
#define U(f)                                                                                                 \
    std::pair { STR(f), &Sketch::f }

void Sketch::_register_methods() {
    register_fns(U(init), U(get_source), U(is_compiled), U(set_path), U(set_config));
    register_signals<Sketch>("built_changed");
}

#undef STR
#undef U

void Sketch::init(String src, Ref<SketchConfig> config) {
    set_path(src);
    set_config(config);
}

void Sketch::set_path(String src) { sketch = smce::Sketch{std_str(src), conf}; }

void Sketch::set_config(Ref<SketchConfig> config) {
    sketch = smce::Sketch{sketch.get_source(), config->to_native()};
}

String Sketch::get_source() { return sketch.get_source().c_str(); }

bool Sketch::is_compiled() { return sketch.is_compiled(); }
