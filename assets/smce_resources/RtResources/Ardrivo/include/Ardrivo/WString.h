/*
 *  WString.h
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
 */

#ifndef WString_h
#define WString_h

#include <stdexcept>
#include <string>
#include <type_traits>
#include <utility>
#include "SMCE_dll.hpp"
#include "SMCE_numeric.hpp"

struct SMCE__BIN : std::integral_constant<int, 2> {};
constexpr SMCE__BIN BIN{};

struct SMCE__DEC : std::integral_constant<int, 10> {};
constexpr SMCE__DEC DEC{};

struct SMCE__HEX : std::integral_constant<int, 16> {};
constexpr SMCE__HEX HEX{};

class SMCE__DLL_RT_API String {
    struct InternalTag {};
    struct ConvTag {};
    constexpr static ConvTag conv_tag{};

#if _MSC_VER
#    pragma warning(push)
#    pragma warning(disable : 4251)
#endif
    std::string m_u;
#if _MSC_VER
#    pragma warning(pop)
#endif

    String(std::string u);

    String(ConvTag, std::uintmax_t val, SMCE__BIN);
    String(ConvTag, std::uintmax_t val, SMCE__HEX);

  public:
#if !SMCE__COMPILING_USERCODE
    constexpr static InternalTag internal_tag{};
#endif
    String(InternalTag, const char*, std::size_t);

    String() noexcept;
    String(const String&);
    String(String&&) noexcept;
    String& operator=(const String&);
    String& operator=(String&&) noexcept;
    ~String();

    template <std::size_t N>
    /* explicit(false) */ String(const char (&charr)[N]) : m_u{charr, N} {}
    /* explicit(false) */ String(const char* cstr);
    explicit String(char c);

    template <class T, class = typename std::enable_if<std::is_integral<T>::value>::type>
    explicit String(T val) : m_u{std::to_string(val)} {}
    template <class T, class = typename std::enable_if<std::is_integral<T>::value>::type>
    String(T val, SMCE__BIN) : String{conv_tag, SMCE__bit_cast<typename std::make_unsigned<T>::type>(val), BIN} {}
    template <class T, class = typename std::enable_if<std::is_integral<T>::value>::type>
    String(T val, SMCE__DEC) : String{val} {}
    template <class T, class = typename std::enable_if<std::is_integral<T>::value>::type>
    String(T val, SMCE__HEX) : String{conv_tag, SMCE__bit_cast<typename std::make_unsigned<T>::type>(val), HEX} {}

    template <class T, class = std::enable_if_t<std::is_floating_point<T>::value>>
    explicit String(T val, [[maybe_unused]] int precision = -1) : m_u{std::to_string(val)} {}

    [[nodiscard]] const char* c_str() const noexcept;
    [[nodiscard]] std::size_t length() const noexcept;
    [[nodiscard]] char charAt(unsigned idx) const noexcept;
    [[nodiscard]] char& charAt(unsigned idx) noexcept;
    [[nodiscard]] char operator[](unsigned idx) const noexcept;
    [[nodiscard]] char& operator[](unsigned idx) noexcept;

    template <class T>
    bool concat(const T& v) {
        m_u += String(v).m_u;
        return true;
    }

    [[nodiscard]] int compareTo(const String& s) const noexcept;

    [[nodiscard]] bool startsWith(const String& s) const noexcept;

    [[nodiscard]] bool endsWith(const String& s) const noexcept;

    void getBytes(std::uint8_t* buffer, unsigned length) const noexcept;

    [[nodiscard]] int indexOf(const char* c) const noexcept;

    [[nodiscard]] int indexOf(const char* c, unsigned index) const noexcept;

    [[nodiscard]] int indexOf(const String& str) const noexcept;

    [[nodiscard]] int indexOf(const String& str, unsigned index) const noexcept;

    void remove(unsigned idx);

    void remove(unsigned idx, unsigned count);

    void replace(const String& substring1, const String& substring2);

    void reserve(unsigned size);

    void setCharAt(unsigned index, char c);

    [[nodiscard]] String substring(unsigned from) const;

    [[nodiscard]] String substring(unsigned from, unsigned to) const;

    void toCharArray(char* buffer, unsigned length) noexcept;

    [[nodiscard]] long toInt() const noexcept;

    [[nodiscard]] double toDouble() const noexcept;

    [[nodiscard]] float toFloat() const noexcept;

    void toLowerCase() noexcept;

    void toUpperCase() noexcept;

    void trim();

    friend SMCE__DLL_RT_API String operator+(const String&, const String&);
    [[nodiscard]] bool equals(const String& s) const noexcept;
    [[nodiscard]] bool equalsIgnoreCase(const String& s) const noexcept;

    [[nodiscard]] bool operator==(const String& s) const noexcept;
    [[nodiscard]] bool operator!=(const String& s) const noexcept;
    [[nodiscard]] bool operator<(const String& s) const noexcept;
    [[nodiscard]] bool operator<=(const String& s) const noexcept;
    [[nodiscard]] bool operator>(const String& s) const noexcept;
    [[nodiscard]] bool operator>=(const String& s) const noexcept;

    friend SMCE__DLL_RT_API String operator+(const String&, const char*);
    friend SMCE__DLL_RT_API String operator+(const char*, const String&);
};

[[nodiscard]] SMCE__DLL_RT_API String operator+(const String& lhs, const String& rhs);
[[nodiscard]] SMCE__DLL_RT_API String operator+(const String& lhs, const char* rhs);
[[nodiscard]] SMCE__DLL_RT_API String operator+(const char* lhs, const String& rhs);

#endif