#ifndef SMCE_GD_CLASS_HXX
#define SMCE_GD_CLASS_HXX

#include <array>
#include <functional>
#include <type_traits>
#include <godot_cpp/classes/global_constants.hpp>
#include <godot_cpp/core/binder_common.hpp>
#include "SMCE_gd/utility.hxx"
#include "godot_cpp/classes/ref_counted.hpp"
#include "godot_cpp/core/class_db.hpp"
#include "godot_cpp/godot.hpp"
#include "godot_cpp/variant/utility_functions.hpp"

using namespace godot;

template <fixed_string Name, class Self, class Base> struct GdClass : public Base {
  private:
    void operator=(const Self& p_rval) {}
    friend class ClassDB;

  protected:
    virtual const char* _get_extension_class() const override { return get_class_static(); }
    virtual const GDNativeInstanceBindingCallbacks* _get_bindings_callbacks() const override {
        return &___binding_callbacks;
    }
    static void (*_get_bind_methods())() { return &Self::_bind_methods; }
    template <class T> static void register_virtuals() { Base::template register_virtuals<T>(); }

  public:
    static void initialize_class() {
        static bool initialized = false;
        if (initialized)
            return;
        Base::initialize_class();
        if (Self::_get_bind_methods() != Base::_get_bind_methods()) {
            Self::_bind_methods();
            Base::template register_virtuals<Self>();
        }
        initialized = true;
    }

    static const char* get_class_static() { return Name.data(); }

    static const char* get_parent_class_static() { return Base::get_class_static(); }

    static GDNativeObjectPtr create(void* data) { return memnew(Self)->_owner; }

    static void free(void* data, GDExtensionClassInstancePtr ptr) {
        if (ptr) {
            Self* cls = reinterpret_cast<Self*>(ptr);
            cls->~Self();
            ::godot::Memory::free_static(cls);
        }
    }

    static constexpr GDNativeInstanceBindingCallbacks ___binding_callbacks = {
        +[](void*, void*) -> void* { return nullptr; },
        +[](void* p_token, void* p_instance, void* p_binding) {},
        +[](void* p_token, void* p_instance, GDNativeBool p_reference) -> GDNativeBool { return true; },
    };

    // Extensions
  protected:
    using This = Self;

    static void bind_method(const char* name, auto func) { ClassDB::bind_method(D_METHOD(name), func); }

    template <auto n> static void bind_enum(const char* enum_name, std::array<const char*, n> names) {
        for (auto i = 0; i < n; ++i) {
            ClassDB::bind_integer_constant(Name.data(), enum_name, names[i], i);
        }
    }

    static void bind_prop(const char* name, Variant::Type type, const char* getter, const char* setter) {
        ClassDB::add_property(Name.data(), PropertyInfo{type, name}, setter, getter);
    }

    template <auto member> auto generic_get() { return static_cast<Self*>(this)->*member; }
    template <auto member, class R> auto generic_set(R v) { static_cast<Self*>(this)->*member = v; }

    template <fixed_string name, Variant::Type type, auto member> static auto bind_getter() {
        constexpr auto getter = fixed_string{"get_"} + name;
        bind_method(getter.data(), &Self::template generic_get<member>);
        return getter;
    }

    template <fixed_string name, Variant::Type type, auto member> static auto bind_setter() {
        constexpr auto setter = fixed_string{"set_"} + name;
        [=]<class R>(R Self::*) {
            bind_method(setter.data(), &Self::template generic_set<member, R>);
        }(member);
        return setter;
    }

    template <fixed_string name, Variant::Type type, auto member> static void bind_prop_rw() {
        const auto getter = bind_getter<name, type, member>();
        const auto setter = bind_setter<name, type, member>();
        bind_prop(name.data(), type, getter.data(), setter.data());
    }
};

template <fixed_string Name, class Self> using GdRef = GdClass<Name, Self, RefCounted>;

#endif