/*
 *  OV767X.h
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

#ifndef OV767X_H
#define OV767X_H

#include <cstddef>
#include "SMCE_dll.hpp"

enum SMCE_OV767_Format {
    RGB888,
    RGB444,
};

enum SMCE_OV767_Resolution {
    VGA,
    CIF,
    QVGA,
    QCIF,
    QQVGA,
};

class SMCE__DLL_RT_API OV767X {
    std::size_t m_key = 0;
    SMCE_OV767_Format m_format;
    bool m_begun = false;

  public:
    OV767X() noexcept;
    ~OV767X();

    void setPins(int vsync, int href, int pclk, int xclk, const int dpins[8]);
    int begin(SMCE_OV767_Resolution resolution, SMCE_OV767_Format format, int fps); // Supported FPS: 1, 5, 10, 15, 30
    void end();

    int width() const;
    int height() const;
    int bitsPerPixel() const;
    int bytesPerPixel() const;

    void readFrame(void* buffer);

    void horizontalFlip();
    void noHorizontalFlip();
    void verticalFlip();
    void noVerticalFlip();
};

extern SMCE__DLL_RT_API OV767X Camera;

#endif // OV767X_H
