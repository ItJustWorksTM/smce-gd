//
// Created by danie on 2021-11-02.
//

#ifndef MKRRGBMATRIX_H
#define MKRRGBMATRIX_H

#include <cstddef>
#include <cstdint>
#include <ArduinoGraphics.h>
#include <FramebufferAccess.h>
#include "SMCE_dll.hpp"

#define RGB_MATRIX_WIDTH 640
#define RGB_MATRIX_HEIGHT 480
#define PIXEL_FORMAT SMCE_Pixel_Format::RGB888
#define BITS_PER_PIXEL 24
#define FPS 60

class RGBMatrixClass : public ArduinoGraphics {
  private:
    FramebufferAccess framebufferAccessor;
    std::byte buf[(BITS_PER_PIXEL * RGB_MATRIX_HEIGHT * RGB_MATRIX_WIDTH) / CHAR_BIT];

  public:
    RGBMatrixClass();
    virtual ~RGBMatrixClass();

    int begin();
    void end();

    void brightness(uint8_t brightness);

    virtual void beginDraw();
    virtual void endDraw();

    virtual void set(int x, int y, uint8_t r, uint8_t g, uint8_t b);
};

extern RGBMatrixClass MATRIX;
#endif // MKRRGBMATRIX_H