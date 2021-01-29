#include <filesystem>
#include <catch2/catch.hpp>
#include <SMCE/BoardRunner.hpp>
#include <SMCE/ExecutionContext.hpp>

#define SMCE_PATH SMCE_TEST_DIR "/smce_root"
#define SKETCHES_PATH SMCE_TEST_DIR "/sketches/"

TEST_CASE("ExecutionContext invalid", "[ExecutionContext]") {
    const auto path = SMCE_TEST_DIR "/empty_dir";
    std::filesystem::create_directory(path);
    smce::ExecutionContext exec_ctx{path};
    REQUIRE_FALSE(exec_ctx.check_suitable_environment());
    REQUIRE(exec_ctx.resource_dir() == path);
}

TEST_CASE("ExecutionContext valid", "[ExecutionContext]") {
    smce::ExecutionContext exec_ctx{SMCE_PATH};
    REQUIRE(exec_ctx.check_suitable_environment());
    REQUIRE(exec_ctx.resource_dir() == SMCE_PATH);
    REQUIRE_FALSE(exec_ctx.cmake_path().empty());
}

TEST_CASE("BoardRunner contracts", "[BoardRunner]") {
    smce::ExecutionContext exec_ctx{SMCE_PATH};
    REQUIRE(exec_ctx.check_suitable_environment());
    smce::BoardRunner br{exec_ctx};
    REQUIRE(br.status() == smce::BoardRunner::Status::clean);
    REQUIRE_FALSE(br.view().valid());
    REQUIRE(br.configure("arduino:avr:nano", {}));
    REQUIRE(br.status() == smce::BoardRunner::Status::configured);
    REQUIRE(br.view().valid());
    REQUIRE(br.build(SKETCHES_PATH "noop", {}));
    REQUIRE(br.status() == smce::BoardRunner::Status::built);
    REQUIRE(br.view().valid());
    REQUIRE(br.start());
    REQUIRE(br.status() == smce::BoardRunner::Status::running);
    REQUIRE(br.view().valid());
    REQUIRE(br.suspend());
    REQUIRE(br.status() == smce::BoardRunner::Status::suspended);
    REQUIRE(br.view().valid());
    REQUIRE(br.resume());
    REQUIRE(br.status() == smce::BoardRunner::Status::running);
    REQUIRE(br.view().valid());
    REQUIRE(br.stop());
    REQUIRE(br.status() == smce::BoardRunner::Status::stopped);
    REQUIRE_FALSE(br.view().valid());
    REQUIRE(br.reset());
    REQUIRE(br.status() == smce::BoardRunner::Status::clean);
    REQUIRE_FALSE(br.view().valid());
}
