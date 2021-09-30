/*
 *  Future.hxx
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

#include <future>
#include "core/Godot.hpp"
#include "util/Extensions.hxx"

namespace godot {

class Future : public Reference {
    GODOT_CLASS(Future, Reference);

  public:
    std::future<Variant> future;
    void _init() {}

    static void _register_methods();

    void wait() { future.wait(); }
    bool poll_ready();

    Variant get() { return future.get(); }
};

class Promise : public Reference {
    GODOT_CLASS(Promise, Reference);

    std::promise<Variant> promise;
    Ref<Future> future;

  public:
    void _init();

    static void _register_methods();

    void set_value(Variant value);

    Ref<Future> get_future() { return future; }
};

} // namespace godot