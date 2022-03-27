#ifndef SMCE_GD_TOOLCHAIN_HXX
#define SMCE_GD_TOOLCHAIN_HXX

#include <memory>
#include "SMCE/Toolchain.hpp"
#include "SMCE_gd/ManifestRegistry.hxx"
#include "SMCE_gd/Result.hxx"
#include "SMCE_gd/Sketch.hxx"
#include "SMCE_gd/gd_class.hxx"

using namespace godot;

class Toolchain;

class ToolchainLogReader : public GdRef<"ToolchainLogReader", ToolchainLogReader> {
    std::shared_ptr<smce::Toolchain> tc;
    friend Toolchain;

  public:
    String read();

    static void _bind_methods();
};

class Toolchain : public GdRef<"Toolchain", Toolchain> {
    Ref<ToolchainLogReader> reader;
    std::shared_ptr<smce::Toolchain> tc;

    String resource_path;
    Ref<ManifestRegistry> registry;

  public:
    Ref<Result> initialize(Ref<ManifestRegistry> _registry, String _resource_path);

    Ref<Result> is_initialized();

    Ref<Result> compile(Ref<Sketch> sketch);

    Ref<ToolchainLogReader> log_reader();

    static void _bind_methods();
};

#endif