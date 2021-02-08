/*
 *  AnalogRaycast.hxx
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


#ifndef GODOT_SMCE_ANALOGRAYCAST_HXX
#define GODOT_SMCE_ANALOGRAYCAST_HXX

#include <SMCE/BoardView.hpp>
#include <core/Godot.hpp>
#include <gen/RayCast.hpp>
#include "bind/BoardView.hxx"

namespace godot {
class AnalogRaycast : public RayCast {
    GODOT_CLASS(AnalogRaycast, RayCast)

  public:
    BoardView* board_view;

    static void _register_methods();

    void _init();

    void _physics_process(float delta);

    void _on_view_invalidated();

    void set_boardview(BoardView* view);
};

} // namespace godot

#endif // GODOT_SMCE_ANALOGRAYCAST_HXX
