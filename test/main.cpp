#include <array>
#include <chrono>
#include <filesystem>
#include <future>
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

TEST_CASE("BoardRunner exit_notify", "[BoardRunner]") {
    smce::ExecutionContext exec_ctx{SMCE_PATH};
    REQUIRE(exec_ctx.check_suitable_environment());
    std::promise<int> ex;
    smce::BoardRunner br{exec_ctx, [&](int ec){ ex.set_value(ec); }};
    REQUIRE(br.configure("arduino:avr:nano", {}));
    REQUIRE(br.build(SKETCHES_PATH "uncaught", {}));
    REQUIRE(br.start());
    auto exfut = ex.get_future();
    int ticks = 0;
    while (ticks++ < 5 && exfut.wait_for(0ms) != std::future_status::ready) {
        exfut.wait_for(1s);
        br.tick();
    }
    REQUIRE(exfut.wait_for(0ms) == std::future_status::ready);
    REQUIRE(exfut.get() != 0);
}

template <class Pin, class Value, class Duration>
void test_pin_delayable(Pin pin, Value expected_value, std::size_t ticks, Duration tick_length) {
    do {
        if(ticks-- == 0)
            FAIL();
        std::this_thread::sleep_for(tick_length);
    } while(pin.read() != expected_value);
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
    std::this_thread::sleep_for(1ms);
    pin0.write(false);
    test_pin_delayable(pin2, true, 16384, 1ms);
    pin0.write(true);
    test_pin_delayable(pin2, false, 16384, 1ms);
    REQUIRE(br.stop());
}

TEST_CASE("BoardView UART", "[BoardView]") {
    smce::ExecutionContext exec_ctx{SMCE_PATH};
    REQUIRE(exec_ctx.check_suitable_environment());
    smce::BoardRunner br{exec_ctx};
    REQUIRE(br.configure("arduino:avr:nano",
     {
       .uart_channels = {{}}
     }
    ));
    REQUIRE(br.build(SKETCHES_PATH "uart", {}));
    auto bv = br.view();
    REQUIRE(bv.valid());
    auto uart0 = bv.uart_channels[0];
    REQUIRE(uart0.exists());
    REQUIRE(uart0.rx().exists());
    REQUIRE(uart0.tx().exists());
    auto uart1 = bv.uart_channels[1];
    REQUIRE_FALSE(uart1.exists());
    REQUIRE_FALSE(uart1.rx().exists());
    REQUIRE_FALSE(uart1.tx().exists());
    REQUIRE(br.start());
    std::this_thread::sleep_for(1ms);
    std::array out = {'H', 'E', 'L', 'L', 'O', ' ', 'U', 'A', 'R', 'T', '\0'};
    std::array<char, out.size()> in{};
    uart0.rx().write(out);
    int ticks = 16'000;
    do {
        if(ticks-- == 0)
            FAIL();
        std::this_thread::sleep_for(1ms);
    } while(uart0.tx().read(in) != in.size());
    REQUIRE(in == out);

    std::reverse(out.begin(), out.end());
    uart0.rx().write(out);
    ticks = 16'000;
    do {
        if(ticks-- == 0)
            FAIL();
        std::this_thread::sleep_for(1ms);
    } while(uart0.tx().read(in) != in.size());
    REQUIRE(in == out);

    REQUIRE(br.stop());
}
