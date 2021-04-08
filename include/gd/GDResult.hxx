/*
 *  SmceError.hxx
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

#ifndef GODOT_SMCE_GDRESULT_HXX
#define GODOT_SMCE_GDRESULT_HXX

#include <core/Godot.hpp>
#include "gd/util.hxx"

namespace godot {
class GDResult : public Reference {
    GODOT_CLASS(GDResult, Reference);
    String err_msg;
    bool has_error = false;

  public:
    static void _register_methods() {
        register_method("error", &GDResult::get_error);
        register_method("ok", &GDResult::is_ok);
        register_method("set_error", &GDResult::set_error);
    }

    static Ref<GDResult> err(String str) {
        auto ret = make_ref<GDResult>();
        ret->set_error(str);
        return ret;
    }

    static Ref<GDResult> ok() { return make_ref<GDResult>(); }

    static Ref<GDResult> from(const std::error_code& ec) {
        if (ec) {
            const auto msg = ec.message();
            return err(msg.c_str());
        }
        return ok();
    }

    void _init() {}

    bool is_ok() { return !has_error; }

    void set_error(String error) {
        if (!has_error)
            err_msg = error;
        has_error = true;
    }

    String get_error() { return err_msg; }
};
} // namespace godot

#endif // GODOT_SMCE_GDRESULT_HXX
