/*
 *  lib.cxx
 *  Copyright 2020 ItJustWorksTM
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

#include <core/Godot.hpp>
#include "types/Result.hxx"
#include "types/bind/board/Board.hxx"
#include "types/bind/board/BoardConfig.hxx"
#include "types/bind/board/BoardDeviceSpec.hxx"
#include "types/bind/board_view/DynamicBoardDevice.hxx"
#include "types/bind/board_view/UartChannel.hxx"
#include "types/bind/sketch/Sketch.hxx"
#include "types/bind/sketch/SketchConfig.hxx"
#include "types/bind/sketch/Toolchain.hxx"
#include "types/sync/Channel.hxx"
#include "types/sync/Future.hxx"

using namespace godot;

extern "C" void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options* o) { Godot::gdnative_init(o); }

extern "C" void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options* o) {
    Godot::gdnative_terminate(o);
}

template <class... T> void register_classes() { (register_class<T>(), ...); };

template <class T> decltype(auto) gd2std(T&& v) { return std::forward<T>(v); }
decltype(auto) std2gd(auto&& v) { return gd2std(v); }

String std2gd(std::string str) { return String{str.c_str()}; }
std::string gd2std(String str) { return std_str(str); }

struct F {
    std::string important = "420";
};
struct T {
    int count;
    std::string hello(std::string str) {
        Godot::print(str.c_str());
        return str;
    }

    int doz(F& f) { Godot::print(f.important.c_str()); }
};

String std2gd(std::string str);

template <class T, fixed_string name> struct GdClass : GdRef<name, GdClass<T, name>> {
    using This = GdClass<T, name>;
    T t = T{};

    template <auto fnptr, class... Args> auto fwd_impl(Args... args) {
        return std2gd((t.*fnptr)(gd2std(args)...));
    }

    template <auto fnptr, class Z, class... Args> auto fwd_impl_standalone(Args... args) {
        return std2gd((*fnptr)(t, gd2std(args)...));
    }

    void _init() {}
};

F& gd2std(Ref<GdClass<F, "FClass">> obj) { return obj->t; }
Ref<GdClass<F, "FClass">> std2gd(F&&);

template <class T, fixed_string name> struct Builder {
    using Z = GdClass<T, name>;

    Builder() { register_class<Z>(); }

    template <fixed_string nm, auto ptr> auto fn() {

        constexpr auto fptr = Visitor{[]<class R, class... Args>(R(T::*)(Args...)){
            return &Z::template fwd_impl<ptr, decltype(std2gd(std::declval<Args>()))...>;
    }
    , []<class R, class... Args>(R (*)(T&, Args...)) {
        return &Z::template fwd_impl_standalone<ptr, T&, decltype(Args{std2gd(std::declval<Args>())})...>;
    }
}(ptr);
register_method(nm.data(), fptr);

return *this;
}
}
;

template <fixed_string name, class Func> struct Fn {};

template <class Getter, class Setter> struct Prop {};

template <class T, class... Items> struct Gdx {

    template <fixed_string func_name> consteval auto fn(auto func) {

        return Gdx<T, Items..., Fn<func_name, decltype(func)>>{};
    }

    void register_as() {
        auto visit = Visitor{[]<fixed_string func_name, class A>(Fn<func_name, A>) {

                             },
                             [](auto) {}};
        ((visit(Items{})), ...);
    }
};

template <class... Base> struct Xx : Base... {
    template <class... Ts>
    constexpr Xx(Ts&&... ts) noexcept((std::is_nothrow_move_constructible_v<Base> && ...))
        : Base{std::forward<Ts>(ts)}... {}
    using Base::operator()...;

    template <class New> auto with(New&& n) {
        return Xx<Visitor<Base...>, New>{std::move(*this), std::forward<New>(n)};
    }
};
template <class... Ts> Xx(Ts...) -> Xx<std::remove_cvref_t<Ts>...>;

extern "C" void GDN_EXPORT godot_nativescript_init(void* handle) {
    Godot::nativescript_init(handle);

    // auto z = [i = 0] {};

    // auto t = Gdx<F>().fn<"func">([](F& self) {});

    // Visitor{};
    // Xx{};
    // auto wtf = Xx{}.with([] {});

    //    static_assert(std::is_same_v<decltype(wtf), void>);

    //    Builder<F, "FClass">{};
    //
    //    constexpr auto odd = +[](T& self, int num) {
    //        Godot::print(Variant{num});
    //        return 420;
    //    };
    //    Builder<T, "TClass">{}.fn<"baz", odd>();
    register_classes<Board, BoardLogReader, Toolchain, ToolchainLogReader, Sketch, SketchConfig,
                     SketchConfig::PluginManifest, DynamicBoardDevice, BoardDeviceMutex, BoardDeviceSpec,
                     BoardView, UartChannel, Result, FrameBuffer, BoardConfig, BoardConfig::GpioDriverConfig,
                     BoardConfig::UartChannelConfig, BoardConfig::FrameBufferConfig,
                     BoardConfig::BoardDeviceConfig, BoardConfig::SecureDigitalStorage, GpioPin, Sender,
                     Receiver, Future, Promise>();
}
