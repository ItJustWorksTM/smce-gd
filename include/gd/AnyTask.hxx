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

#ifndef GODOT_SMCE_ANYTASK_HXX
#define GODOT_SMCE_ANYTASK_HXX

#include <functional>
#include <future>
#include <core/Godot.hpp>
#include <gen/Reference.hpp>
#include "gd/util.hxx"

namespace godot {

class AnyTask : public Reference {
    GODOT_CLASS(AnyTask, Reference)

    std::future<Ref<AnyTask>> thread;

  public:
    static auto _register_methods() -> void {
        register_signal<AnyTask>("completed", Dictionary{});
        register_method("_completed", &AnyTask::_completed);
    }

    template <class F>
    static Ref<AnyTask> make_awaitable(F&& task) {
        static_assert(std::is_invocable_r_v<Variant, F>);
        auto runner = make_ref<AnyTask>();
        runner->thread = std::async([runner, task = std::forward<F>(task)]() mutable {
            runner->call_deferred("_completed", task());
            return runner;
        });

        return runner;
    }

    void _completed(Variant ret) {
        emit_signal("completed", ret);
        thread.get();
    }

    void _init() {}
};
} // namespace godot

#endif // GODOT_SMCE_ANYTASK_HXX
