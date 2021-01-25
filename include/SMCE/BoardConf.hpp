/*
 *  BoardConf.hpp
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

#ifndef SMCE_BOARDCONF_HPP
#define SMCE_BOARDCONF_HPP

#include <cstdint>
#include <optional>
#include <vector>

namespace smce {

struct BoardConfig {
    struct GpioDrivers {
        struct DigitalDriver {
            bool board_read;
            bool board_write;
        };
        struct AnalogDriver {
            bool board_read;
            bool board_write;
//          std::size_t width;
        };
        std::uint16_t pin_id{};
        std::optional<DigitalDriver> digital_driver;
        std::optional<AnalogDriver> analog_driver;
    };
    struct UartChannel {
        std::optional<std::uint16_t> rx_pin_override;
        std::optional<std::uint16_t> tx_pin_override;
        std::uint16_t baud_rate = 9600;
        std::size_t rx_buffer_length = 64;
        std::size_t tx_buffer_length = 64;
        std::size_t flushing_threshold = 0;
    };
/*
    struct I2cBus {
        std::optional<std::uint16_t> rx_pin_override;
        std::optional<std::uint16_t> tx_pin_override;
    };
*/
    std::vector<std::uint16_t> pins;
    std::vector<GpioDrivers> gpio_drivers;
    std::vector<UartChannel> uart_channels;
//  std::vector<I2cBus> i2c_buses;
};

}

#endif // SMCE_BOARDCONF_HPP
