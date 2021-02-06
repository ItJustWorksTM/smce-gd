/*
 *  BoardRunner.hxx
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

#ifndef GODOT_SMCE_BOARDRUNNER_HXX
#define GODOT_SMCE_BOARDRUNNER_HXX

#include <functional>
#include <optional>
#include <type_traits>
#include "SMCE/BoardConf.hpp"
#include "SMCE/BoardRunner.hpp"
#include "SMCE/ExecutionContext.hpp"
#include "SMCE/SketchConf.hpp"
#include "bind/BoardView.hxx"
#include "bind/ExecutionContext.hxx"
#include "bind/UartSlurper.hxx"
#include "core/Godot.hpp"
#include "gd/AnyTask.hxx"
#include "gd/util.hxx"
#include "gen/Node.hpp"
#include "gen/Reference.hpp"

namespace godot {

class BoardRunner : public Node {
    GODOT_CLASS(BoardRunner, Node)

    std::optional<smce::BoardRunner> runner;

    template <auto func, class... Args>
    std::invoke_result_t<decltype(func), smce::BoardRunner> fw_wrap(Args&&... args) {
        if (!runner)
            return false;
        decltype(auto) ret = std::invoke(func, *runner, std::forward<Args>(args)...);
        emit_status();
        return std::move(ret);
    }

    void emit_status();

  public:
    smce::ExecutionContext exec_context = smce::ExecutionContext{"."};

    BoardView* view_node;
    UartSlurper* uart_node;

    BoardView* view();

    UartSlurper* uart();

    void _init();

    static void _register_methods();

    bool init_context(String context_path);

    String context();

    // TODO: take a real BoardConfig
    bool configure(String pp_fqbn);

    // TODO: take a real SketchConfig
    Ref<AnyTask> build(const String sketch_src);

    bool terminate();

    int status();

    std::optional<smce::BoardRunner>& native();
};
} // namespace godot

#endif // GODOT_SMCE_BOARDRUNNER_HXX
