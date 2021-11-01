/*
 *  util.hxx
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

#ifndef GODOT_SMCE_EXTENSIONS_HXX
#define GODOT_SMCE_EXTENSIONS_HXX

#include <string>
#include <tuple>
#include <vector>
#include <core/Godot.hpp>

template <class T> auto make_ref() -> godot::Ref<T> {
    static_assert(std::is_base_of_v<godot::Reference, T>);
    return godot::Ref<T>(T::_new());
}

template <class T, class... S> constexpr auto register_signals(S... name) {
    (register_signal<T>(name, godot::Dictionary{}), ...);
};

template <class... T> constexpr auto register_fns(std::pair<const char*, T>... func) {
    (register_method(func.first, func.second), ...);
};

template <class... T> constexpr auto register_props(T... prop) {
    (register_property(std::get<0>(prop), std::get<1>(prop), std::get<2>(prop)), ...);
};

inline std::string std_str(const godot::String& str) {
    return {str.alloc_c_string(), static_cast<size_t>(str.length())};
}

inline std::vector<std::string> std_str_vec(const godot::Array& arr) {
    auto ret = std::vector<std::string>(arr.size());

    for (size_t i = 0; i < arr.size(); ++i) {
        ret.push_back(std::move(std_str(static_cast<godot::String>(arr[i]))));
    }

    return ret;
}

template <class... Base> struct Visitor : Base... {
    template <class... Ts>
    constexpr Visitor(Ts&&... ts) noexcept((std::is_nothrow_move_constructible_v<Base> && ...))
        : Base{std::forward<Ts>(ts)}... {}
    using Base::operator()...;
};
template <class... Ts> Visitor(Ts...) -> Visitor<std::remove_cvref_t<Ts>...>;

template <size_t N> struct fixed_string {
    char content[N] = {0};

    constexpr fixed_string(const char (&input)[N]) {
        for (size_t i = 0; i < N; ++i)
            content[i] = input[i];
    }

    [[nodiscard]] constexpr const char* data() const { return +content; }
};

template <> struct fixed_string<0> {
    char content[1] = {0};

    constexpr fixed_string(const char*) {}
};

template <fixed_string Name, class Self, class Base> struct GdScript : public Base {
    inline static const char* ___get_class_name() { return Name.data(); }
    enum { ___CLASS_IS_SCRIPT = 1 };
    inline static const char* ___get_godot_class_name() { return Base::___get_godot_class_name(); }
    inline static Self* _new() { return godot::detail::create_custom_class_instance<Self>(); }
    inline static size_t ___get_id() { return typeid(Self).hash_code(); }
    inline static size_t ___get_base_id() { return Base::___get_id(); }
    inline static const char* ___get_base_class_name() { return Base::___get_class_name(); }
    inline static godot::Object* ___get_from_variant(godot::Variant a) {
        return (godot::Object*)godot::detail::get_custom_class_instance<Self>(
            godot::Object::___get_from_variant(a));
    }

    static void _register_methods() {}
    void _init() {}

    using This = Self;
};

template <fixed_string Name, class Base> using GdRef = GdScript<Name, Base, godot::Reference>;

#endif // GODOT_SMCE_EXTENSIONS_HXX
