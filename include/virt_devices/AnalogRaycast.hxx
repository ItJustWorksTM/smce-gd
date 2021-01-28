//
// Created by ruthgerd on 1/24/21.
//

#ifndef GODOT_SMCE_ANALOGRAYCAST_HXX
#define GODOT_SMCE_ANALOGRAYCAST_HXX

#include "core/Godot.hpp"
#include "gen/RayCast.hpp"
#include "SMCE/BoardView.hpp"
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

}

#endif //GODOT_SMCE_ANALOGRAYCAST_HXX
