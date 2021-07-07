/*
 *  Stream.h
 *  Copyright 2020-2021 ItJustWorksTM
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

#ifndef Stream_h
#define Stream_h
#include "Print.h"
#include "SMCE_dll.hpp"

#define NO_IGNORE_CHAR '\x01'
#define DEFAULT_TIMEOUT 1000

// clang-format off
enum LookaheadMode {
    SKIP_ALL,
    SKIP_NONE,
    SKIP_WHITESPACE
};
// clang-format on

class SMCE__DLL_RT_API Stream : public Print {
    long _timeout{DEFAULT_TIMEOUT};

  protected:
    int peekNextDigit(LookaheadMode lookahead, bool detectDecimal);

  public:
    virtual int available() = 0;
    virtual int read() = 0;
    virtual int peek() = 0;

    Stream() = default;

    [[nodiscard]] bool find(char target) noexcept { return find(&target, 0); }
    [[nodiscard]] bool find(const char* target, int length) noexcept {
        return findUntil(target, length, NO_IGNORE_CHAR);
    }
    [[nodiscard]] bool findUntil(char target, char terminal) noexcept { return findUntil(&target, 0, terminal); }
    [[nodiscard]] bool findUntil(const char* target, int length, char terminal) noexcept;
    size_t readBytes(char* buffer, int length) { return readBytesUntil(NO_IGNORE_CHAR, buffer, length); }
    size_t readBytesUntil(char character, char* buffer, int length);
    String readString() { return readStringUntil(NO_IGNORE_CHAR); }
    String readStringUntil(char terminator);
    long parseInt(LookaheadMode lookahead = SKIP_ALL, char ignore = NO_IGNORE_CHAR);
    float parseFloat(LookaheadMode lookahead = SKIP_ALL, char ignore = NO_IGNORE_CHAR);
    void setTimeout(long time);
};

#endif // Stream_h
