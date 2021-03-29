/*
 *  OV767X.cpp
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

#include <array>
#include <climits>
#include <iostream>
#include <utility>
#include <SMCE/BoardView.hpp>
#include "OV767X.h"

namespace smce {
extern BoardView board_view;
extern void maybe_init();
}

SMCE__DLL_API OV767X Camera;

OV767X::OV767X() noexcept = default;
OV767X::~OV767X() = default;

void OV767X::setPins([[maybe_unused]] int vsync, [[maybe_unused]] int href, [[maybe_unused]] int pclk, [[maybe_unused]] int xclk, [[maybe_unused]] const int dpins[8]) {

}

/*
 *   VGA = 0,  // 640x480
  CIF = 1,  // 352x240
  QVGA = 2, // 320x240
  QCIF = 3,  // 176x144
  QQVGA = 4,  // 160x120
 * */

constexpr std::array<std::pair<uint16_t, uint16_t>, 5> resolutions{{
    {640, 480},
    {352, 240},
    {320, 240},
    {176, 144},
    {160, 120},
}};

int OV767X::begin(SMCE_OV767_Resolution resolution, SMCE_OV767_Format format, int fps) {
    if(format != RGB888) {
        std::cerr << "OV767X::begin: invalid value " << +format << " specified as format" << std::endl;
        return -1;
    }

    if(resolution >= resolutions.size()) {
        std::cerr << "OV767X::begin: invalid value " << +resolution << " specified as resolution" << std::endl;
        return -1;
    }

    auto fb = smce::board_view.frame_buffers[m_key];
    fb.set_width(resolutions[resolution].first);
    fb.set_height(resolutions[resolution].second);
    fb.set_freq(static_cast<std::uint8_t>(fps));

    m_begun = true;
    return 0;
}

void OV767X::end() {
    auto fb = smce::board_view.frame_buffers[m_key];
    fb.set_width(0);
    fb.set_height(0);
    fb.set_freq(0);
    m_begun = false;
}


int OV767X::width() const {
    return smce::board_view.frame_buffers[m_key].get_width();
}

int OV767X::height() const {
    return smce::board_view.frame_buffers[m_key].get_height();
}

int OV767X::bitsPerPixel() const {
    return bytesPerPixel() * CHAR_BIT;
}

int OV767X::bytesPerPixel() const {
    return 3;
}


void OV767X::readFrame(void* buffer) {
    smce::board_view.frame_buffers[m_key].read_rgb888({static_cast<std::byte*>(buffer), static_cast<std::size_t>(bytesPerPixel() * width() * height())});
}


void OV767X::horizontalFlip() {
    smce::board_view.frame_buffers[m_key].needs_horizontal_flip(true);
}

void OV767X::noHorizontalFlip() {
    smce::board_view.frame_buffers[m_key].needs_horizontal_flip(false);
}

void OV767X::verticalFlip() {
    smce::board_view.frame_buffers[m_key].needs_vertical_flip(true);
}

void OV767X::noVerticalFlip() {
    smce::board_view.frame_buffers[m_key].needs_vertical_flip(false);
}
