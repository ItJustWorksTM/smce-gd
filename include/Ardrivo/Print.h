/*
 *  Print.h
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

#ifndef Print_h
#define Print_h

#include <cstddef>
#include <cstdint>
#include <cstring>
#include <iterator>
#include "SMCE_dll.hpp"
#include "WString.h"

class SMCE__DLL_RT_API Print {
    int write_error = 0;

  protected:
    void setWriteError(int err = 1) noexcept;

  public:
    Print() noexcept;
    [[nodiscard]] int getWriteError() noexcept;
    void clearWriteError() noexcept;

    virtual std::size_t write(std::uint8_t) = 0;
    virtual std::size_t write(const uint8_t* buffer, std::size_t size);
    std::size_t write(const char* str);
    std::size_t write(const char* buffer, size_t size);

    // should be overridden by subclasses with buffering
    virtual int availableForWrite();

    template <std::size_t N>
    std::size_t print(const char (&lit)[N]) {
        return write(lit, N);
    }
    std::size_t print(const String& s);
    std::size_t print(const char* czstr);
    std::size_t print(char c);
    template <class Int, class Base = SMCE__DEC, class = typename std::enable_if<std::is_integral<Int>::value>::type>
    inline std::size_t print(Int val, Base = DEC) {
        return print(String{val, Base{}});
    }
    template <class Fp, class = typename std::enable_if<std::is_floating_point<Fp>::value>::type>
    inline std::size_t print(Fp val, int prec = 2) {
        return print(String{val, prec});
    }
    // std::size_t print(const struct Printable&); // FIXME: implement base Printable

    template <std::size_t N>
    std::size_t println(const char (&lit)[N]) {
        return write(lit, N) + println();
    }
    std::size_t println(const String& s);
    std::size_t println(const char* czstr);
    std::size_t println(char c);
    template <class Int, class Base = SMCE__DEC, class = typename std::enable_if<std::is_integral<Int>::value>::type>
    std::size_t println(Int val, Base = DEC) {
        return print(val, Base{}) + println();
    }
    template <class Fp, class = typename std::enable_if<std::is_floating_point<Fp>::value>::type>
    inline std::size_t println(Fp val, int prec = 2) {
        return print(val, prec) + println();
    }
    // inline std::size_t println(const Printable& p) { return print(p) + println(); }
    std::size_t println();

    virtual void flush(); // Empty implementation for backward compatibility
};

#endif // Print_h