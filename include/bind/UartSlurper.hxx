/*
 *  UartSlurper.hxx
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

#ifndef GODOT_SMCE_UARTSLURPER_HXX
#define GODOT_SMCE_UARTSLURPER_HXX

#include <unordered_map>
#include <vector>
#include "core/Godot.hpp"
#include "gen/Node.hpp"
#include "BoardView.hxx"

namespace godot {
class UartSlurper : public Node {
    GODOT_CLASS(UartSlurper, Node)
    friend BoardRunner;

    smce::BoardView view;

    void setup_bufs(smce::BoardView view);

    struct UartBuffer {
        size_t available;
        std::vector<char> read_buf;
        std::vector<char> write_buf;
    };

    std::vector<UartBuffer> bufs;

  public:
    static void _register_methods();

    void _init();

    bool write(int channel, String msg);

    int channels();

    void _physics_process(float delta);
};
} // namespace godot

#endif // GODOT_SMCE_UARTSLURPER_HXX
