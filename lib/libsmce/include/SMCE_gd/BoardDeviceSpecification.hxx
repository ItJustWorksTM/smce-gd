#ifndef SMCE_GD_BOARDDEVICESPECIFICATION_HXX
#define SMCE_GD_BOARDDEVICESPECIFICATION_HXX

#include "SMCE/BoardDeviceSpecification.hpp"
#include "SMCE_gd/gd_class.hxx"
#include "godot_cpp/classes/ref_counted.hpp"
using namespace godot;

struct BoardDeviceSpecification : public GdRef<"BoardDeviceSpecification", BoardDeviceSpecification> {

    String name;
    Dictionary fields;

    static void _bind_methods() {
        bind_enum("FieldType", std::array{"u8",  "u16",  "u32",  "u64",  "s8",   "s16",  "s32",
                                          "s64", "f32",  "f64",  "au8",  "au16", "au32", "au64",
                                          "as8", "as16", "as32", "as64", "af32", "af64", "mutex"});

        bind_prop_rw<"device_name", Variant::Type::STRING, &This::name>();
        bind_prop_rw<"fields", Variant::Type::DICTIONARY, &This::fields>();
    }

    smce::BoardDeviceSpecification to_native() {
        auto ret = smce::BoardDeviceSyntheticSpecification{
            .name = to_utf8(name),
            .version = "1.0.0",
        };

        const auto keys = fields.keys();

        for (std::size_t i = 0; i < keys.size(); ++i)
            ret.fields[to_utf8(keys[i])] =
                static_cast<smce::BoardDeviceFieldType>(static_cast<int>(fields.get(keys[i], -1)));

        return ret;
    }
};

#endif