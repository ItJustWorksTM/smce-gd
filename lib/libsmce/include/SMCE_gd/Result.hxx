#ifndef SMCE_GD_RESULT_HXX
#define SMCE_GD_RESULT_HXX

#include <system_error>
#include "SMCE_gd/gd_class.hxx"
#include "SMCE_gd/utility.hxx"
#include "godot_cpp/classes/ref_counted.hpp"
#include "godot_cpp/godot.hpp"
using namespace godot;

class Result : public GdRef<"Result", Result> {

    bool is_error = false;
    Variant value = Variant{};

  public:
    static void _bind_methods();

    Ref<Result> set_err(Variant err_value);
    Ref<Result> set_ok(Variant ok_value);
    Ref<Result> set_if_err(bool is_ok, Variant ok_value);
    Ref<Result> err_from(Ref<Result> res, Variant ok_value);

    Ref<Result> set(bool is_ok, Variant val);

    [[nodiscard]] bool is_err() const;
    [[nodiscard]] bool is_ok() const;

    [[nodiscard]] Variant get_value();

    [[nodiscard]] static Ref<Result> ok();
    [[nodiscard]] static Ref<Result> err(const Variant& err_value);

    [[nodiscard]] static Ref<Result> from(std::error_code ec);

    String to_string();
};

#endif