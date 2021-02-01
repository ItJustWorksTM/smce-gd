#include <chrono>
#include <filesystem>
#include <catch2/catch.hpp>
#include <SMCE/BoardRunner.hpp>
#include <SMCE/ExecutionContext.hpp>

#define SMCE_PATH SMCE_TEST_DIR "/smce_root"
#define SKETCHES_PATH SMCE_TEST_DIR "/sketches/"

using namespace std::literals;

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

TEST_CASE("BoardView GPIO", "[BoardView]") {
    smce::ExecutionContext exec_ctx{SMCE_PATH};
    REQUIRE(exec_ctx.check_suitable_environment());
    smce::BoardRunner br{exec_ctx};
    REQUIRE(br.configure("arduino:avr:nano",
      {
        .pins = {0, 2},
        .gpio_drivers = {
          smce::BoardConfig::GpioDrivers {
            .pin_id = 0,
            .digital_driver = smce::BoardConfig::GpioDrivers::DigitalDriver{
                .board_read = true,
                .board_write = false
            },
            .analog_driver = smce::BoardConfig::GpioDrivers::AnalogDriver{
              .board_read = true,
              .board_write = false
            }
          },
          smce::BoardConfig::GpioDrivers {
              .pin_id = 2,
              .digital_driver = smce::BoardConfig::GpioDrivers::DigitalDriver{
                  .board_read = false,
                  .board_write = true
              },
              .analog_driver = smce::BoardConfig::GpioDrivers::AnalogDriver{
                  .board_read = false,
                  .board_write = true
              }
          },
        }
      }
    ));
    REQUIRE(br.build(SKETCHES_PATH "pins", {}));
    auto bv = br.view();
    REQUIRE(bv.valid());
    auto pin0 = bv.pins[0].digital();
    REQUIRE(pin0.exists());
    auto pin1 = bv.pins[1].digital();
    REQUIRE_FALSE(pin1.exists());
    auto pin2 = bv.pins[2].digital();
    REQUIRE(pin2.exists());
    REQUIRE(br.start());
    std::this_thread::sleep_for(10ms);
    pin0.write(false);
    std::this_thread::sleep_for(10ms);
    REQUIRE(pin2.read());
    pin0.write(true);
    std::this_thread::sleep_for(1ms);
    REQUIRE_FALSE(pin2.read());
    REQUIRE(br.stop());
}
