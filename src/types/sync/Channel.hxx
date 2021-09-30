/*
 *  Channel.hxx
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

#include <deque>
#include <memory>
#include <mutex>
#include <utility>
#include <core/Godot.hpp>
#include <gen/Reference.hpp>
#include "util/Extensions.hxx"

namespace godot {

struct Channel {
    std::mutex lock{};
    std::deque<Variant> queue{};
};

class Receiver;
class Sender;

class Receiver : public Reference {
    GODOT_CLASS(Receiver, Reference);

  public:
    void _init() {}
    static void _register_methods();

    std::shared_ptr<Channel> internal{};
    Variant recv();

    Ref<Sender> new_sender();
};

class Sender : public Reference {
    GODOT_CLASS(Sender, Reference);

  public:
    void _init() {}

    static void _register_methods();

    std::shared_ptr<Channel> internal{};
    bool send(Variant val);

    Ref<Receiver> new_receiver();
};

} // namespace godot
