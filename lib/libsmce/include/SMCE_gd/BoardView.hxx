
#ifndef GODOT_SMCE_BOARDVIEW_HXX
#define GODOT_SMCE_BOARDVIEW_HXX

#include <functional>
#include <type_traits>
#include <SMCE/BoardConf.hpp>
#include <SMCE/BoardView.hpp>
#include "SMCE_gd/BoardConfig.hxx"
#include "SMCE_gd/gd_class.hxx"
#include "SMCE_gd/utility.hxx"
#include "godot_cpp/classes/ref_counted.hpp"
#include "godot_cpp/godot.hpp"

using namespace godot;
class Board;

class BoardView : public GdRef<"BoardView", BoardView> {
    friend Board;

    smce::BoardView view;
    bool valid = false;

    Dictionary pins;
    Array uart_channels;
    Dictionary frame_buffers;
    Dictionary /* <String, Array<DynamicBoardDevice>> */ board_devices;

  public:
    static void _bind_methods();

    void _init();

    smce::BoardView native();

    static Ref<BoardView> from_native(Ref<BoardConfig> info, smce::BoardView viw);

    void poll();

    bool is_valid() { return valid; }

    template <auto v> auto get_valid() {
        return valid ? this->*v : std::remove_cvref_t<decltype(this->*v)>{};
    }
    void set_noop(auto) {}
};

#endif // GODOT_SMCE_BOARDVIEW_HXX