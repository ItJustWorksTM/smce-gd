/*
 *  FrameBuffer.hxx
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

#ifndef GODOT_SMCE_FRAMEBUFFER_HXX
#define GODOT_SMCE_FRAMEBUFFER_HXX

#include <SMCE/BoardView.hpp>
#include <core/Godot.hpp>
#include <gen/Image.hpp>
#include <gen/Reference.hpp>

namespace godot {

class BoardView;

class FrameBuffer : public Reference {
    GODOT_CLASS(FrameBuffer, Reference)
    friend BoardView;

    smce::FrameBuffer frame_buf;

  public:
    FrameBuffer() : frame_buf(smce::BoardView{}.frame_buffers[0]) {}

    static void _register_methods();
    void _init() {}

    bool exists();
    bool needs_horizontal_flip() noexcept;
    bool needs_vertical_flip() noexcept;
    int get_width() noexcept;
    int get_height() noexcept;
    int get_freq() noexcept;
    bool write_rgb888(Ref<Image> img);
    PoolByteArray read_rgb888();
};
}; // namespace godot

#endif // GODOT_SMCE_FRAMEBUFFER_HXX
