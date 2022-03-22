/*
 *  lib.cxx
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

#include <core/Godot.hpp>
#include "bind/Board.hxx"
#include "bind/BoardConfig.hxx"
#include "bind/Sketch.hxx"
#include "bind/Toolchain.hxx"
#include "bind/UartSlurper.hxx"
#include "gd/AnyTask.hxx"
#include "gd/GDResult.hxx"
#include "gd/BraceEnabler.hxx"

using namespace godot;

extern "C" void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options* o) { Godot::gdnative_init(o); }

extern "C" void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options* o) {
    Godot::gdnative_terminate(o);
}

template <class... T> void register_classes() { (register_class<T>(), ...); };

extern "C" void GDN_EXPORT godot_nativescript_init(void* handle) {
    Godot::nativescript_init(handle);

    register_classes<AnyTask, Board, Toolchain, Sketch, BoardView, UartSlurper, GDResult, FrameBuffer,
                     BoardConfig, BoardConfig::GpioDriverConfig, BoardConfig::UartChannelConfig,
                     BoardConfig::FrameBufferConfig, BoardConfig::SecureDigitalStorage, BraceEnabler>();
}
