/*
 *  Channel.cxx
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

#include "Channel.hxx"

using namespace godot;

void Receiver::_register_methods() {
    register_method("recv", &Receiver::recv);
    register_method("new_sender", &Receiver::new_sender);
}

Variant Receiver::recv() {
    std::scoped_lock lk{internal->lock};
    auto& queue = internal->queue;

    if (queue.empty()) {
        return Variant{};
    } else {
        // TODO: perform some UB to avoid a variant copy call
        auto ret = Variant{queue.front()};
        queue.pop_front();

        return ret;
    }
}

Ref<Sender> Receiver::new_sender() {
    auto channel = std::make_shared<Channel>();

    this->internal = channel;
    auto r = make_ref<Sender>();
    r->internal = channel;

    return r;
}

void Sender::_register_methods() {
    register_method("send", &Sender::send);
    register_method("new_receiver", &Sender::new_receiver);
}

bool Sender::send(Variant val) {
    std::scoped_lock lk{internal->lock};
    internal->queue.push_back(val);
    return true;
}

Ref<Receiver> Sender::new_receiver() {
    auto channel = std::make_shared<Channel>();

    this->internal = channel;
    auto r = make_ref<Receiver>();
    r->internal = channel;

    return r;
}
