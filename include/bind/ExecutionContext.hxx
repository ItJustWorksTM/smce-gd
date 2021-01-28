/*
 *  ExecutionContext.hxx
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

#ifndef GODOT_SMCE_EXECUTIONCONTEXT_HXX
#define GODOT_SMCE_EXECUTIONCONTEXT_HXX

#include "core/Godot.hpp"
#include "SMCE/ExecutionContext.hpp"

namespace godot {
    class ExecutionContext : public Reference {
    GODOT_CLASS(ExecutionContext, Reference)

        smce::ExecutionContext context = smce::ExecutionContext{"."};

    public:
        static void _register_methods();

        static Ref<ExecutionContext> make_context(String path);

        void _init();

        smce::ExecutionContext &native();

        String resource_dir();

        bool check_suitable_environment();
    };
}


#endif //GODOT_SMCE_EXECUTIONCONTEXT_HXX
