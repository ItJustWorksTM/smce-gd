
#ifndef GODOT_SMCE_FRAMEBUFFER_HXX
#define GODOT_SMCE_FRAMEBUFFER_HXX

#include <SMCE/BoardView.hpp>
#include "SMCE_gd/BoardConfig.hxx"
#include "SMCE_gd/gd_class.hxx"
#include "SMCE_gd/utility.hxx"
#include "godot_cpp/godot.hpp"

using namespace godot;
class BoardView;

class FrameBuffer : public GdRef<"FrameBuffer", FrameBuffer> {
    friend BoardView;

    smce::FrameBuffer frame_buf = smce::BoardView{}.frame_buffers[0];

    Ref<BoardConfig::FrameBufferConfig> m_info;

  public:
    static Ref<FrameBuffer> from_native(Ref<BoardConfig::FrameBufferConfig> info, smce::FrameBuffer fb);

    static void _bind_methods();

    bool exists();
    bool needs_horizontal_flip() noexcept;
    bool needs_vertical_flip() noexcept;
    int get_width() noexcept;
    int get_height() noexcept;
    int get_freq() noexcept;
    bool write_rgb888(PackedByteArray img);
    PackedByteArray read_rgb888();

    Ref<BoardConfig::FrameBufferConfig> info();
};

#endif // GODOT_SMCE_FRAMEBUFFER_HXX