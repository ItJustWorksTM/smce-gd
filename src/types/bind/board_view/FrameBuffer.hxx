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
#include <core/PoolArrays.hpp>
#include <gen/Reference.hpp>
#include "types/bind/board/BoardConfig.hxx"
#include "util/Extensions.hxx"

namespace godot {

class BoardView;

class FrameBuffer : public GdRef<"FrameBuffer", FrameBuffer> {
    friend BoardView;

    smce::FrameBuffer frame_buf = smce::BoardView{}.frame_buffers[0];

    Ref<BoardConfig::FrameBufferConfig> m_info;

  public:
    static Ref<FrameBuffer> from_native(Ref<BoardConfig::FrameBufferConfig> info, smce::FrameBuffer fb);

    static void _register_methods();

    bool exists();
    bool needs_horizontal_flip() noexcept;
    bool needs_vertical_flip() noexcept;
    int get_width() noexcept;
    int get_height() noexcept;
    int get_freq() noexcept;
    bool write_rgb888(PoolByteArray img);
    PoolByteArray read_rgb888();

    Ref<BoardConfig::FrameBufferConfig> info();
};
}; // namespace godot

#endif // GODOT_SMCE_FRAMEBUFFER_HXX
