/*
 *  EmulGlue.hxx
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

#ifndef GODOT_SMCE_UTIL_HXX
#define GODOT_SMCE_UTIL_HXX
#include <filesystem>
#include <optional>
#include <utility>
#include <BoardConf.hxx>
#include <BoardData.hxx>
#include <BoardInfo.hxx>
#include <Godot.hpp>

template<typename T>
T* gd_cast(const godot::Object* variant) {
    return godot::Object::cast_to<T>(variant);
}


std::optional<std::pair<BoardData, BoardInfo>> make_config(const std::filesystem::path& path);

#endif //GODOT_SMCE_UTIL_HXX
