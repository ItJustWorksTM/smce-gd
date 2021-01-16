# libSMCE
_Spiritual successor to the backend of SMartCarEmul_

Status: *EXPERIMENTAL*

### API draft

```cpp
namespace smce {

struct ExecutionContext {
  explicit ExecutionContext(stdfs::path smce_resources_dir);
  std::error_code check_suitable_environment() noexcept;
};


struct BoardConfig {
  struct GpioDrivers {
    struct DigitalDriver {
      bool board_read;
      bool board_write;
    };
    struct AnalogDriver {
      bool board_read;
      bool board_write;
      std::size_t register_width;
    };
    std::uint16_t pin_id;
    std::optional<DigitalDriverConf> digital_driver;
    std::optional<AnalogDriverConf> analog_driver;
  };
  struct UartChannel {
    std::optional<std::uint16_t> rx_pin_override;
    std::optional<std::uint16_t> tx_pin_override;
    std::uint16_t baud_rate;
    std::size_t flushing_threshold;
  };
  struct I2cBus {
    std::optional<std::uint16_t> rx_pin_override;
    std::optional<std::uint16_t> tx_pin_override;
  };
  std::vector<std::uint16_t> pins;
  std::vector<GpioPin> gpio_drivers;
  std::vector<UartChannel> uart_channels;
  std::vector<I2cBus> i2c_buses;
};


struct SketchConfig {
  struct FreestandingLibrary {
    stdfs::path include_dir; /// Include directory for that library
    stdfs::path archive_path;  /// Path to that library's binary; empty if none
    std::vector<std::string> compile_defs;  /// Arguments to CMake's target_compile_definitions
  };
  struct RemoteArduinoLibrary {
    std::string name; // Library name as found in the install command
    std::string version; // Version string; empty if latest
  };
  struct LocalArduinoLibrary {
    stdfs::path root_dir;
  };
  using Library = std::variant<FreestandingLibrary, RemoteArduinoLibrary, LocalArduinoLibrary>;
  std::vector<std::string> extra_board_uris; /// Extra board.txt URIs for ArduinoCLI
  std::vector<Library> preproc_libs; /// Libraries to use during preprocessing
  std::vector<Library> complink_libs; /// Libraries to use at compile and link time
  std::vector<std::string> extra_compile_defs; /// Arguments to CMake's target_compile_definitions
  std::vector<std::string> extra_compile_opts; /// Arguments to CMake's target_compile_options
};


struct VirtualDigitalDriver {
  bool exists();
  VirtualDigitalDriver& operator=(bool);
  operator bool();
  operator bool&();
};
struct VirtualAnalogDriver {
  bool exists();
  VirtualAnalogDriver& operator=(std::uint16_t);
  operator std::uint16_t();
  operator std::uint16_t&();
};

struct VirtualPin {
  bool exists();
  bool locked();
  VirtualDigitalDriver digital();
  VirtualAnalogDriver analog();
};

struct VirtualPins {
  VirtualPin operator[](std::size_t);
  ConstIterator cbegin();
  Iterator begin();
  ConstIterator cend();
  Iterator end();
  std::size_t size();
};

struct VirtualUartBuffer {
  bool exists();
  std::size_t read(std::span<std::byte> buf);
  std::size_t write(std::span<const std::byte> buf);
  std::size_t size() const;
  std::vector<std::byte> expensive_copy() const;
  std::pmr::vector<std::byte> expensive_copy(std::memory_resource*) const;
};

struct VirtualUart {
  bool exists();
  VirtualUartBuffer rx;
  VirtualUartBuffer tx;
};

struct VirtualUarts {
  VirtualPin operator[](std::size_t);
  ConstIterator cbegin();
  Iterator begin();
  ConstIterator cend();
  Iterator end();
  std::size_t size();
};

struct VirtualI2cMaster {
  void write_to(std::uint8_t slave_addr, std::uint8_t reg, std::vector<std::byte>);
  void read_from(std::uint8_t slave_addr, std::uint8_t reg, std::span<std::byte>);
};

struct VirtualI2cSlave {
  bool exists();
  void set_handler(std::function<void(bool, std::span<std::byte>)>);
};

struct VirtualI2cSlaves {
  VirtualI2cSlave operator[](std::uint8_t);
  ConstIterator cbegin();
  Iterator begin();
  ConstIterator cend();
  Iterator end();
  std::size_t size();
  bool insert(std::uint8_t);
  bool remove(std::uint8_t);
};

struct VirtualI2c {
  bool exists();
  VirtualI2cMaster master;
  VirtualI2cSlaves slaves;
};

struct VirtualI2cs {
  VirtualI2c operator[](std::size_t);
  ConstIterator cbegin();
  Iterator begin();
  ConstIterator cend();
  Iterator end();
  std::size_t size();
};

struct VirtualOpaqueDevices {
  std::any* operator[](std::string_view key) noexcept;
  bool insert(std::string_view key, std::any value);
  bool emplace(std::string_view key, auto&& value);
  template <class T>
  bool emplace(std::string_view key, auto&&... args);
  bool erase(std::string_view key);
};

struct BoardView {
  VirtualPins pins;
  VirtualUarts uart_channels;
  VirtualI2cs i2c_buses;
  VirtualOpaqueDevices opaque_devices;
};

struct BoardRunner {
  enum class Status {
    clean,
    configured,
    loaded,
    running,
    suspended,
    terminated,
  };
  
  explicit BoardRunner(ExecutionContext& ctx);
  
  Status status() const noexcept;
  BoardView view() noexcept;
  
  /// \internal
  template <Status new_status, class... Args>
  std::error_code transition(Args...) noexcept;
  
  
  std::error_code reset() noexcept { return transition<Status::clean>(); }
  std::error_code configure(std::string_view pp_fqbn, BoardConfig bconf) noexcept { return transition<Status::configured>(pp_fqbn, bconf); }
  std::error_code load(stdfs::path sketch_src, const SketchConfig& skonf) noexcept { return transition<Status::loaded>(sketch_src, libraries); }
  std::error_code start() noexcept { return transition<Status::running>(); }
  std::error_code suspend() noexcept { return transition<Status::suspended>(); }
  std::error_code resume() noexcept { return transition<Status::running>(); }
  std::error_code terminate() noexcept { return transition<Status::terminated>(); }
};

}
```
