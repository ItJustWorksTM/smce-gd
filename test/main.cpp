#include <array>
#include <chrono>
#include <filesystem>
#include <fstream>
#include <future>
#include <iostream>
#include <thread>
#include <catch2/catch.hpp>
#include "SMCE/Board.hpp"
#include "SMCE/Sketch.hpp"
#include "SMCE/Toolchain.hpp"

#define SMCE_PATH SMCE_TEST_DIR "/smce_root"
#define SKETCHES_PATH SMCE_TEST_DIR "/sketches/"
#define PATCHES_PATH SMCE_TEST_DIR "/patches/"
#define STORAGE_PATH SMCE_TEST_DIR "/storage/"

using namespace std::literals;

TEST_CASE("ExecutionContext invalid", "[ExecutionContext]") {
    const auto path = SMCE_TEST_DIR "/empty_dir";
    std::filesystem::create_directory(path);
    smce::Toolchain tc{path};
    REQUIRE(tc.check_suitable_environment());
    REQUIRE(tc.resource_dir() == path);
}

TEST_CASE("ExecutionContext valid", "[ExecutionContext]") {
    smce::Toolchain tc{SMCE_PATH};
    REQUIRE(!tc.check_suitable_environment());
    REQUIRE(tc.resource_dir() == SMCE_PATH);
    REQUIRE_FALSE(tc.cmake_path().empty());
}

TEST_CASE("BoardRunner contracts", "[BoardRunner]") {
    smce::Toolchain tc{SMCE_PATH};
    REQUIRE(!tc.check_suitable_environment());
    smce::Sketch sk{SKETCHES_PATH "noop", {.fqbn = "arduino:avr:nano"}};
    const auto ec = tc.compile(sk);
    if (ec)
        std::cerr << tc.build_log().second;
    REQUIRE_FALSE(ec);
    REQUIRE(sk.is_compiled());
    smce::Board br{};
    REQUIRE(br.status() == smce::Board::Status::clean);
    REQUIRE_FALSE(br.view().valid());
    REQUIRE(br.configure({}));
    REQUIRE(br.status() == smce::Board::Status::configured);
    REQUIRE_FALSE(br.view().valid());
    REQUIRE(br.attach_sketch(sk));
    REQUIRE_FALSE(br.view().valid());
    REQUIRE(br.start());
    REQUIRE(br.status() == smce::Board::Status::running);
    REQUIRE(br.view().valid());
    REQUIRE(br.suspend());
    REQUIRE(br.status() == smce::Board::Status::suspended);
    REQUIRE(br.view().valid());
    REQUIRE(br.resume());
    REQUIRE(br.status() == smce::Board::Status::running);
    REQUIRE(br.view().valid());
    REQUIRE(br.stop());
    REQUIRE(br.status() == smce::Board::Status::stopped);
    REQUIRE_FALSE(br.view().valid());
    REQUIRE(br.reset());
    REQUIRE(br.status() == smce::Board::Status::clean);
    REQUIRE_FALSE(br.view().valid());
}

TEST_CASE("BoardRunner exit_notify", "[BoardRunner]") {
    smce::Toolchain tc{SMCE_PATH};
    REQUIRE(!tc.check_suitable_environment());
    smce::Sketch sk{SKETCHES_PATH "uncaught", {.fqbn = "arduino:avr:nano"}};
    const auto ec = tc.compile(sk);
    if (ec)
        std::cerr << tc.build_log().second;
    REQUIRE_FALSE(ec);
    std::promise<int> ex;
    smce::Board br{[&](int ec) { ex.set_value(ec); }};
    REQUIRE(br.configure({}));
    REQUIRE(br.attach_sketch(sk));
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
        if (ticks-- == 0)
            FAIL("Timed out pin-wait");
        std::this_thread::sleep_for(tick_length);
    } while (pin.read() != expected_value);
}

TEST_CASE("BoardView GPIO", "[BoardView]") {
    smce::Toolchain tc{SMCE_PATH};
    REQUIRE(!tc.check_suitable_environment());
    smce::Sketch sk{SKETCHES_PATH "pins", {.fqbn = "arduino:avr:nano"}};
    const auto ec = tc.compile(sk);
    if (ec)
        std::cerr << tc.build_log().second;
    REQUIRE_FALSE(ec);
    smce::Board br{};
    // clang-format off
    REQUIRE(br.configure({
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
    }));
    // clang-format on
    REQUIRE(br.attach_sketch(sk));
    REQUIRE(br.start());
    auto bv = br.view();
    REQUIRE(bv.valid());
    auto pin0 = bv.pins[0].digital();
    REQUIRE(pin0.exists());
    auto pin1 = bv.pins[1].digital();
    REQUIRE_FALSE(pin1.exists());
    auto pin2 = bv.pins[2].digital();
    REQUIRE(pin2.exists());
    std::this_thread::sleep_for(1ms);

    pin0.write(false);
    test_pin_delayable(pin2, true, 16384, 1ms);
    pin0.write(true);
    test_pin_delayable(pin2, false, 16384, 1ms);
    REQUIRE(br.stop());
}

TEST_CASE("BoardView UART", "[BoardView]") {
    smce::Toolchain tc{SMCE_PATH};
    REQUIRE(!tc.check_suitable_environment());
    smce::Sketch sk{SKETCHES_PATH "uart", {.fqbn = "arduino:avr:nano"}};
    const auto ec = tc.compile(sk);
    if (ec)
        std::cerr << tc.build_log().second;
    REQUIRE_FALSE(ec);
    smce::Board br{};
    REQUIRE(br.configure({.uart_channels = {{}}}));
    REQUIRE(br.attach_sketch(sk));
    REQUIRE(br.start());
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
    std::this_thread::sleep_for(1ms);

    std::array out = {'H', 'E', 'L', 'L', 'O', ' ', 'U', 'A', 'R', 'T', '\0'};
    std::array<char, out.size()> in{};
    uart0.rx().write(out);
    int ticks = 16'000;
    do {
        if (ticks-- == 0)
            FAIL();
        std::this_thread::sleep_for(1ms);
    } while (uart0.tx().read(in) != in.size());
    REQUIRE(in == out);

    std::reverse(out.begin(), out.end());
    uart0.rx().write(out);
    ticks = 16'000;
    do {
        if (ticks-- == 0)
            FAIL();
        std::this_thread::sleep_for(1ms);
    } while (uart0.tx().read(in) != in.size());
    REQUIRE(in == out);

    REQUIRE(br.stop());
}

TEST_CASE("Mixed INO/C++ sources", "[BoardRunner]") {
    smce::Toolchain tc{SMCE_PATH};
    REQUIRE(!tc.check_suitable_environment());
    smce::Sketch sk{SKETCHES_PATH "with_cxx", {.fqbn = "arduino:avr:nano"}};
    const auto ec = tc.compile(sk);
    if (ec)
        std::cerr << tc.build_log().second;
    REQUIRE_FALSE(ec);
}

#if SMCE_ARDRIVO_MQTT

TEST_CASE("BoardRunner remote preproc lib", "[BoardRunner]") {
    smce::Toolchain tc{SMCE_PATH};
    REQUIRE(!tc.check_suitable_environment());
    // clang-format off
    smce::Sketch sk{SKETCHES_PATH "remote_pp", {
        .fqbn = "arduino:avr:nano",
        .preproc_libs = { smce::SketchConfig::RemoteArduinoLibrary{"MQTT", ""} }
    }};
    // clang-format on
    const auto ec = tc.compile(sk);
    if (ec)
        std::cerr << tc.build_log().second;
    REQUIRE_FALSE(ec);
}

TEST_CASE("WiFi intended use", "[WiFi]") {
    smce::Toolchain tc{SMCE_PATH};
    REQUIRE(!tc.check_suitable_environment());
    // clang-format off
    smce::Sketch sk{SKETCHES_PATH "wifi", {
        .fqbn = "arduino:avr:nano",
        .preproc_libs = {
            smce::SketchConfig::RemoteArduinoLibrary{"WiFi", ""},
            smce::SketchConfig::RemoteArduinoLibrary{"MQTT", ""}
        }
    }};
    // clang-format on
    const auto ec = tc.compile(sk);
    if (ec)
        std::cerr << tc.build_log().second;
    REQUIRE_FALSE(ec);
}

#endif // SMCE_ARDRIVO_MQTT

TEST_CASE("Patch lib", "[BoardRunner]") {
    smce::Toolchain tc{SMCE_PATH};
    REQUIRE(!tc.check_suitable_environment());
    // clang-format off
    smce::Sketch sk{SKETCHES_PATH "patch", {
        .fqbn = "arduino:avr:nano",
        .complink_libs = { smce::SketchConfig::LocalArduinoLibrary{PATCHES_PATH "ESP32_analogRewrite", "ESP32 AnalogWrite"} }
    }};
    // clang-format on
    const auto ec = tc.compile(sk);
    if (ec)
        std::cerr << tc.build_log().second;
    REQUIRE_FALSE(ec);
    smce::Board br{};
    // clang-format off
    REQUIRE(br.configure({
        .pins = {0},
        .gpio_drivers = {
            smce::BoardConfig::GpioDrivers {
                .pin_id = 0,
                .analog_driver = smce::BoardConfig::GpioDrivers::AnalogDriver{
                    .board_read = false,
                    .board_write = true
                }
            }
        }
    }));
    // clang-format on
    REQUIRE(br.attach_sketch(sk));
    REQUIRE(br.start());
    auto bv = br.view();
    auto pin0 = bv.pins[0].analog();
    REQUIRE(pin0.exists());
    std::this_thread::sleep_for(1ms);
    test_pin_delayable(pin0, 42, 16384, 1ms);
    REQUIRE(br.stop());
}

TEST_CASE("SD polyfill", "[SD File]") {
    smce::Toolchain tc{SMCE_PATH};
    REQUIRE(!tc.check_suitable_environment());
    // clang-format off
    smce::Sketch sk{SKETCHES_PATH "sd_fs", {
        .fqbn = "arduino:avr:nano",
        .preproc_libs = { smce::SketchConfig::RemoteArduinoLibrary{"SD", ""} }
    }};
    // clang-format on
    const auto ec = tc.compile(sk);
    if (ec)
        std::cerr << ec.message() << '\n' << tc.build_log().second << std::endl;
    REQUIRE_FALSE(ec);

    smce::Board br{};
    // clang-format off
    REQUIRE(br.configure({
        .pins = {0},
        .gpio_drivers = {
            smce::BoardConfig::GpioDrivers{
                .pin_id = 0,
                .digital_driver = smce::BoardConfig::GpioDrivers::DigitalDriver{
                    .board_read = true,
                    .board_write = true
                }
            }
        },
        .sd_cards = {
            smce::BoardConfig::SecureDigitalStorage{ .root_dir = STORAGE_PATH }
        }
    }));
    // clang-format on

    if (std::filesystem::exists(STORAGE_PATH))
        std::filesystem::remove_all(STORAGE_PATH);
    std::filesystem::create_directory(STORAGE_PATH);
    REQUIRE(br.attach_sketch(sk));
    REQUIRE(br.start());
    auto d0 = br.view().pins[0].digital();
    test_pin_delayable(d0, true, 16384, 1ms); // wait for the pin to be set
    REQUIRE(br.stop());
    std::cerr << br.runtime_log().second << std::endl;

    REQUIRE(std::filesystem::exists(STORAGE_PATH "foo"));
    REQUIRE(std::filesystem::is_directory(STORAGE_PATH "foo"));
    REQUIRE(std::filesystem::exists(STORAGE_PATH "bar"));
    REQUIRE(std::filesystem::is_directory(STORAGE_PATH "bar"));
    REQUIRE(std::filesystem::exists(STORAGE_PATH "bar/baz"));
    REQUIRE(std::filesystem::is_regular_file(STORAGE_PATH "bar/baz"));
    std::ifstream baz{STORAGE_PATH "bar/baz"};
    REQUIRE(baz.is_open());
    std::string s;
    baz >> s;
    REQUIRE(s == "quxx");
}