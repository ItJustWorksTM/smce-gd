#ifndef SMCE_GD_BOARDDEVICE_HXX
#define SMCE_GD_BOARDDEVICE_HXX

#include <algorithm>
#include <ranges>
#include <string>
#include <unordered_map>
#include <SMCE_rt/SMCE_proxies.hpp>
#include <fwd.hpp>
#include "SMCE/BoardDeviceFieldType.hpp"
#include "SMCE/BoardDeviceView.hpp"
#include "SMCE/BoardView.hpp"
#include "SMCE_gd/BoardDeviceSpecification.hxx"
#include "SMCE_gd/gd_class.hxx"
#include "SMCE_gd/utility.hxx"
#include "godot_cpp/core/class_db.hpp"
#include "godot_cpp/variant/variant.hpp"

class BoardDevice;
class VirtualDeviceMutex : public GdRef<"VirtualDeviceMutex", VirtualDeviceMutex> {
    friend BoardDevice;

    smce_rt::Mutex inner;

  public:
    void lock() { inner.lock(); }
    bool try_lock() { return inner.try_lock(); }
    void unlock() { inner.unlock(); }

    static void _bind_methods() {
        bind_method("lock", &This::lock);
        bind_method("try_lock", &This::try_lock);
        bind_method("unlock", &This::try_lock);
    }
};

class BoardDevice : public GdRef<"BoardDevice", BoardDevice> {
    smce::BoardView shit{};
    smce::VirtualDevice inner = smce::BoardDeviceView(shit)[""][0];

    struct GetSet {
        smce::BoardView shit{};
        smce::VirtualDeviceField field = smce::BoardDeviceView(shit)[""][0][""];

        Variant (*getter)(smce::VirtualDeviceField field);
        Variant get() { return (*getter)(field); }

        bool (*setter)(smce::VirtualDeviceField field, Variant);
        bool set(Variant v) { return (*setter)(field, v); }
    };

    std::unordered_map<std::string, GetSet> fields;

    template <auto op> consteval static auto integral_getset() {
        return [](auto device_field) {
            return GetSet{
                .field = device_field,
                .getter = [](auto field) -> Variant { return static_cast<Variant>((field.*op)()); },
                .setter =
                    [](auto field, Variant v) {
                        (field.*op)() = v;
                        return true;
                    },

            };
        };
    };

  public:
    static void _bind_methods() {
        bind_method("get", &This::get);
        bind_method("set", &This::set);
    }

    virtual Variant get(String field) {
        const auto key = to_utf8(field);
        if (fields.contains(key)) {
            return fields[key].get();
        }
        return Variant{};
    }

    virtual bool set(String field, Variant val) {
        const auto key = to_utf8(field);
        if (fields.contains(key)) {
            return fields[key].set(val);
        }
        return false;
    }

    static Ref<BoardDevice> from_native(smce::VirtualDevice device,
                                        const smce::BoardDeviceSpecification& spec) {
        auto ret = make_ref<BoardDevice>();
        ret->inner = device;

        for (const auto& [k, _] : spec) {

            auto device_field = device[k];

            using enum smce::BoardDeviceFieldType;
            using VField = smce::VirtualDeviceField;

#define Integeral(typ)                                                                                       \
    case typ:                                                                                                \
        return integral_getset<&VField::as_##typ>()(device_field)

            ret->fields[std::string{k}] = [&]() -> GetSet {
                switch (device_field.type()) {
                    Integeral(af64);
                    Integeral(af32);
                    Integeral(as64);
                    Integeral(as32);
                    // Integeral(as16);
                    // Integeral(as8);
                    Integeral(au64);
                    Integeral(au32);
                    // Integeral(au16);
                    // Integeral(au8);
                    Integeral(f64);
                    Integeral(f32);
                    Integeral(s64);
                    Integeral(s32);
                    // Integeral(s16);
                    // Integeral(s8);
                    Integeral(u64);
                    Integeral(u32);
                    // Integeral(u16);
                    // Integeral(u8);
                case mutex:
                    return GetSet{.field = device_field,
                                  .getter =
                                      [](auto field) {
                                          auto ret = make_ref<VirtualDeviceMutex>();
                                          ret->inner = field.as_mutex();
                                          return Variant(ret);
                                      },
                                  .setter = [](auto, Variant) { return false; }};
                default:
                    std::exit(-1);
                    break;
                }
            }();
        };

        return ret;
    }
};

#endif