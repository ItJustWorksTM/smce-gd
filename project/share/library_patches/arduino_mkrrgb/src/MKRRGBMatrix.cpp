//
// Created by danie on 2021-11-02.
//

#include "MKRRGBMatrix.h"

RGBMatrixClass MATRIX;

RGBMatrixClass::RGBMatrixClass()
    : ArduinoGraphics(RGB_MATRIX_WIDTH, RGB_MATRIX_HEIGHT), framebufferAccessor() {}

RGBMatrixClass::~RGBMatrixClass() {}

int RGBMatrixClass::begin() {
    return framebufferAccessor.begin(RGB_MATRIX_WIDTH, RGB_MATRIX_HEIGHT, PIXEL_FORMAT, FPS);
}

void RGBMatrixClass::end() { framebufferAccessor.end(); }

void RGBMatrixClass::brightness(uint8_t brightness) {}

void RGBMatrixClass::beginDraw() {
    ArduinoGraphics::beginDraw();
    framebufferAccessor.read(buf);
}

void RGBMatrixClass::endDraw() {
    ArduinoGraphics::endDraw();
    framebufferAccessor.write(buf);
}

void RGBMatrixClass::set(int x, int y, uint8_t r, uint8_t g, uint8_t b) {
    int index = (y * RGB_MATRIX_WIDTH + x) * (BITS_PER_PIXEL / CHAR_BIT);
    buf[index] = static_cast<std::byte>(r);
    buf[index + 1] = static_cast<std::byte>(g);
    buf[index + 2] = static_cast<std::byte>(b);
}