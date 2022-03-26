
#ifndef SMCE_GD_UTILITY_HXX
#define SMCE_GD_UTILITY_HXX

#include <cstddef>
#include <string_view>
#include <type_traits>
#include "godot_cpp/godot.hpp"
#include "godot_cpp/variant/utility_functions.hpp"

using namespace godot;

template <class... Base> struct Visitor : Base... {
    template <class... Ts>
    constexpr Visitor(Ts&&... ts) noexcept((std::is_nothrow_move_constructible_v<Base> && ...))
        : Base{std::forward<Ts>(ts)}... {}
    using Base::operator()...;
};
template <class... Ts> Visitor(Ts...) -> Visitor<std::remove_cvref_t<Ts>...>;

template <std::size_t N> struct fixed_string {
    char content[N] = {0};

    constexpr fixed_string(const char (&input)[N]) {
        for (size_t i = 0; i < N; ++i)
            content[i] = input[i];
    }

    [[nodiscard]] constexpr const char* data() const { return +content; }

    template <std::size_t M> constexpr fixed_string<N + M - 1> operator+(fixed_string<M> rh) {

        constexpr std::size_t total = N + M - 1;
        char contents[total] = {0};

        for (std::size_t i = 0; i < N - 1; ++i) {
            contents[i] = content[i];
        }

        for (std::size_t i = 0; i < M - 1; ++i) {
            contents[N - 1 + i] = rh.content[i];
        }
        auto ret = fixed_string<total>{contents};

        return ret;
    }
};

template <> struct fixed_string<0> {
    char content[1] = {0};

    constexpr fixed_string(const char*) {}
};

inline std::u32string_view as_view(const String& string) {
    return std::u32string_view{string.ptr(), static_cast<std::size_t>(string.length())};
}

inline std::string to_utf8(const String& string) {
    const auto buffer = string.to_utf8_buffer();

    return std::string{std::string_view{reinterpret_cast<const char*>(buffer.ptr()),
                                        static_cast<std::size_t>(buffer.size())}};
}

template <class T> inline Ref<T> make_ref() {
    auto ref = Ref<T>();
    ref.instantiate();
    return ref;
}

#endif