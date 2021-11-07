/*
 *  Result.hxx
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

#ifndef SMCE_GD_RESULT_HXX
#define SMCE_GD_RESULT_HXX

#include <system_error>
#include <core/Godot.hpp>
#include "util/Extensions.hxx"

namespace godot {
class Result : public GdRef<"Result", Result> {

    bool is_error = false;
    Variant value = Variant{};

  public:
    static void _register_methods() {
        register_method("get_value", &Result::get_value);
        register_method("_to_string", &Result::_to_string);
        register_method("set_err", &Result::set_err);
        register_method("err_from", &Result::err_from);
        register_method("set_ok", &Result::set_ok);
        register_method("is_err", &Result::is_err);
        register_method("is_ok", &Result::is_ok);
        register_method("set_if_err", &Result::set_if_err);
    }

    Ref<Result> set_err(Variant err_value) { return set(false, err_value); }
    Ref<Result> set_ok(Variant ok_value) { return set(true, ok_value); }
    Ref<Result> set_if_err(bool is_ok, Variant ok_value) { return is_ok ? this : set(true, ok_value); }
    Ref<Result> err_from(Ref<Result> res, Variant ok_value) {
        return res->is_err() ? set(false, res->value) : set(true, ok_value);
    }

    Ref<Result> set(bool is_ok, Variant val) {
        value = val;
        is_error = !is_ok;
        return this;
    } // NOLINT(performance-unnecessary-value-param)

    [[nodiscard]] bool is_err() const { return is_error; }
    [[nodiscard]] bool is_ok() const { return !is_err(); }

    [[nodiscard]] Variant get_value() { return value; }

    [[nodiscard]] static Ref<Result> ok() { return make_ref<Result>(); }
    [[nodiscard]] static Ref<Result> err(const Variant& err_value) {
        return make_ref<Result>()->set_err(err_value);
    }

    [[nodiscard]] static Ref<Result> from(std::error_code ec) {
        return !ec ? ok() : err(String{ec.message().c_str()});
    }

    String _to_string() { return String{(is_err() ? "Err" : "Ok")} + "(" + (value.operator String() + ")"); }
};
} // namespace godot

#endif // SMCE_GD_RESULT_HXX
