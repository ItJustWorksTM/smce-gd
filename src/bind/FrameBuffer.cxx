/*
 *  FrameBuffer.cxx
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

#include <span>
#include "bind/FrameBuffer.hxx"

using namespace godot;

void FrameBuffer::_register_methods() {
    register_method("exists", &FrameBuffer::exists);
    register_method("needs_horizontal_flip", &FrameBuffer::needs_horizontal_flip);
    register_method("needs_vertical_flip", &FrameBuffer::needs_vertical_flip);
    register_method("get_width", &FrameBuffer::get_width);
    register_method("get_height", &FrameBuffer::get_height);
    register_method("get_freq", &FrameBuffer::get_freq);
    register_method("write_rgb888", &FrameBuffer::write_rgb888);
    register_method("read_rgb888", &FrameBuffer::read_rgb888);
}

bool FrameBuffer::exists() { return frame_buf.exists(); }
bool FrameBuffer::needs_horizontal_flip() noexcept { return frame_buf.needs_vertical_flip(); }
bool FrameBuffer::needs_vertical_flip() noexcept { return frame_buf.needs_horizontal_flip(); }
int FrameBuffer::get_width() noexcept { return frame_buf.get_width(); }
int FrameBuffer::get_height() noexcept { return frame_buf.get_height(); }
int FrameBuffer::get_freq() noexcept { return frame_buf.get_freq(); }

bool FrameBuffer::write_rgb888(Ref<Image> img) {
    img->convert(Image::Format::FORMAT_RGB8);
    auto bytes = img->get_data();

    if (bytes.size() <= 0)
        return false;

    const auto byte_span =
        std::span{reinterpret_cast<const std::byte*>(bytes.read().ptr()), static_cast<size_t>(bytes.size())};

    return frame_buf.write_rgb888(byte_span);
}

PoolByteArray FrameBuffer::read_rgb888() {
    auto bytes = PoolByteArray{};

    bytes.resize(get_height() * get_width() * 3);

    const auto byte_span =
        std::span{reinterpret_cast<std::byte*>(bytes.write().ptr()), static_cast<size_t>(bytes.size())};

    // TODO: maybe check success :|
    frame_buf.read_rgb888(byte_span);

    return bytes; // pray for some kind of return value optimization
}
