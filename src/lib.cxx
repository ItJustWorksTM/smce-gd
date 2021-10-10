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
#include "types/Result.hxx"
#include "types/bind/board/Board.hxx"
#include "types/bind/board/BoardConfig.hxx"
#include "types/bind/board/BoardDeviceSpec.hxx"
#include "types/bind/board_view/DynamicBoardDevice.hxx"
#include "types/bind/board_view/UartChannel.hxx"
#include "types/bind/sketch/Sketch.hxx"
#include "types/bind/sketch/SketchConfig.hxx"
#include "types/bind/sketch/Toolchain.hxx"
#include "types/sync/Channel.hxx"
#include "types/sync/Future.hxx"

using namespace godot;

extern "C" void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options* o) { Godot::gdnative_init(o); }

extern "C" void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options* o) {
    Godot::gdnative_terminate(o);
}

template <class... T> void register_classes() { (register_class<T>(), ...); };

extern "C" void GDN_EXPORT godot_nativescript_init(void* handle) {
    Godot::nativescript_init(handle);

    register_classes<Board, BoardLogReader, Toolchain, ToolchainLogReader, Sketch, SketchConfig,
                     SketchConfig::PluginManifest, DynamicBoardDevice, BoardDeviceMutex, BoardDeviceSpec,
                     BoardView, UartChannel, Result, FrameBuffer, BoardConfig, BoardConfig::GpioDriverConfig,
                     BoardConfig::UartChannelConfig, BoardConfig::FrameBufferConfig,
                     BoardConfig::BoardDeviceConfig, BoardConfig::SecureDigitalStorage, GpioPin, Sender,
                     Receiver, Future, Promise>();
}
