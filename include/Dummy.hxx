/*
 *  Dummy.hxx
 *  Copyright 2020 ItJustWorksTM
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

#ifndef GODOT_SMCE_DUMMY_HXX
#define GODOT_SMCE_DUMMY_HXX

#include <gen/Node.hpp>
#include <core/Godot.hpp>

namespace godot {
    class Dummy : public Node {
    GODOT_CLASS(Dummy, Node)

    public:
        static auto _register_methods() -> void {
            register_method("_ready", &Dummy::_ready);
            register_method("_process", &Dummy::_process);
        }

        auto _init() -> void;

        auto _ready() -> void;

        auto _process(float delta) -> void;
    };
}


#endif //GODOT_SMCE_DUMMY_HXX
