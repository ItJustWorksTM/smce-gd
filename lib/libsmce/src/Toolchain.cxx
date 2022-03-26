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

bool Toolchain::initialize(Ref<ManifestRegistry> _registry, String _resource_path) {
    resource_path = _resource_path;
    registry = _registry;

    tc = std::make_shared<smce::Toolchain>(as_view(_resource_path));
    reader = Ref<ToolchainLogReader>();
    reader.instantiate();

    reader->tc = tc;

    return is_initialized();
}

Ref<ToolchainLogReader> Toolchain::log_reader() { return reader; }

bool Toolchain::is_initialized() {
    const auto res = tc && !tc->check_suitable_environment();

    return res;
}

bool Toolchain::compile(Ref<Sketch> sketch) {
    if (!is_initialized())
        return false;

    sketch->resolve_config(registry);
    auto& native = sketch->as_native();

    const auto ec = tc->compile(native);

    return !ec;
}

void Toolchain::_bind_methods() {
    bind_method("initialize", &This::initialize);
    bind_method("is_initialized", &This::is_initialized);
    bind_method("log_reader", &This::log_reader);
    bind_method("compile", &This::compile);
}