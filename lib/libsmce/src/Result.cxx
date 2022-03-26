#include "SMCE_gd/Result.hxx"

Ref<Result> Result::set_err(Variant err_value) { return set(false, err_value); }
Ref<Result> Result::set_ok(Variant ok_value) { return set(true, ok_value); }
Ref<Result> Result::set_if_err(bool is_ok, Variant ok_value) { return is_ok ? this : set(true, ok_value); }
Ref<Result> Result::err_from(Ref<Result> res, Variant ok_value) {
    return res->is_err() ? set(false, res->value) : set(true, ok_value);
}

Ref<Result> Result::set(bool is_ok, Variant val) {
    value = val;
    is_error = !is_ok;
    return this;
} // NOLINT(performance-unnecessary-value-param)

bool Result::is_err() const { return is_error; }
bool Result::is_ok() const { return !is_err(); }

Variant Result::get_value() { return value; }

Ref<Result> Result::ok() { return make_ref<Result>(); }
Ref<Result> Result::err(const Variant& err_value) { return make_ref<Result>()->set_err(err_value); }

Ref<Result> Result::from(std::error_code ec) { return !ec ? ok() : err(String{ec.message().c_str()}); }

void Result::_bind_methods() {
    bind_method("get_value", &Result::get_value);
    bind_method("to_string", &Result::to_string);
    bind_method("set_err", &Result::set_err);
    bind_method("err_from", &Result::err_from);
    bind_method("set_ok", &Result::set_ok);
    bind_method("is_err", &Result::is_err);
    bind_method("is_ok", &Result::is_ok);
    bind_method("set_if_err", &Result::set_if_err);
}

String Result::to_string() {
    return String{(is_err() ? "Err" : "Ok")} + "(" + (value.operator String() + ")");
}