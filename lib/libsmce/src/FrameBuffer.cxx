
#include <span>
#include "SMCE_gd/FrameBuffer.hxx"

using namespace godot;

Ref<FrameBuffer> FrameBuffer::from_native(Ref<BoardConfig::FrameBufferConfig> info, smce::FrameBuffer fb) {
    auto ret = make_ref<This>();
    ret->frame_buf = fb;
    ret->m_info = info;
    return ret;
}

void FrameBuffer::_bind_methods() {
    bind_method("exists", &This::exists);
    bind_method("needs_horizontal_flip", &This::needs_horizontal_flip);
    bind_method("needs_vertical_flip", &This::needs_vertical_flip);
    bind_method("get_width", &This::get_width);
    bind_method("get_height", &This::get_height);
    bind_method("get_freq", &This::get_freq);
    bind_method("write_rgb888", &This::write_rgb888);
    bind_method("read_rgb888", &This::read_rgb888);
    bind_method("info", &This::info);
}

bool FrameBuffer::exists() { return frame_buf.exists(); }
bool FrameBuffer::needs_horizontal_flip() noexcept { return frame_buf.needs_vertical_flip(); }
bool FrameBuffer::needs_vertical_flip() noexcept { return frame_buf.needs_horizontal_flip(); }
int FrameBuffer::get_width() noexcept { return frame_buf.get_width(); }
int FrameBuffer::get_height() noexcept { return frame_buf.get_height(); }
int FrameBuffer::get_freq() noexcept { return frame_buf.get_freq(); }

bool FrameBuffer::write_rgb888(PackedByteArray bytes) {
    if (bytes.size() <= 0)
        return false;

    const auto byte_span =
        std::span{reinterpret_cast<const std::byte*>(bytes.ptr()), static_cast<size_t>(bytes.size())};

    return frame_buf.write_rgb888(byte_span);
}

PackedByteArray FrameBuffer::read_rgb888() {
    auto bytes = PackedByteArray{};

    bytes.resize(get_height() * get_width() * 3);

    const auto byte_span =
        std::span{reinterpret_cast<std::byte*>(bytes.ptrw()), static_cast<size_t>(bytes.size())};

    // TODO: maybe check success :|
    frame_buf.read_rgb888(byte_span);

    return bytes; // pray for some kind of return value optimization
}

Ref<BoardConfig::FrameBufferConfig> FrameBuffer::info() { return m_info; }