#include "SMCE_gd/Toolchain.hxx"
#include "SMCE_gd/utility.hxx"

String ToolchainLogReader::read() {
    if (!tc)
        return String();
    if (auto [_, str] = tc->build_log(); !str.empty()) {
        auto ret = String{str.c_str()};
        str.clear();

        return ret;
    }
    return String();
}

void ToolchainLogReader::_bind_methods() { bind_method("read", &This::read); }

Ref<Result> Toolchain::initialize(Ref<ManifestRegistry> _registry, String _resource_path) {
    resource_path = _resource_path;
    registry = _registry;

    tc = std::make_shared<smce::Toolchain>(as_view(_resource_path));
    reader = make_ref<ToolchainLogReader>();
    reader->tc = tc;

    return is_initialized();
}

Ref<ToolchainLogReader> Toolchain::log_reader() { return reader; }

Ref<Result> Toolchain::is_initialized() {
    if (!tc)
        return Result::err(String{"Internal toolchain missing"});
    return Result::from(tc->check_suitable_environment());
}

Ref<Result> Toolchain::compile(Ref<Sketch> sketch) {
    const auto early_ec = is_initialized();
    if (early_ec->is_err())
        return early_ec;

    sketch->resolve_config(registry);
    auto& native = sketch->as_native();

    const auto ec = tc->compile(native);

    return Result::from(ec);
}

void Toolchain::_bind_methods() {
    bind_method("initialize", &This::initialize);
    bind_method("is_initialized", &This::is_initialized);
    bind_method("log_reader", &This::log_reader);
    bind_method("compile", &This::compile);
}