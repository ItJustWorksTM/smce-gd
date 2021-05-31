# libSMCE
_Spiritual successor to the backend of [SMartCarEmul](https://github.com/ItJustWorksTM/SmartcarEmul)_  
_Copyright © ItJustWorks™_

![Build](https://github.com/ItJustWorksTM/libSMCE/workflows/Build/badge.svg?branch=master)

Status: _Actively maintained_

This cross-platform C++ library provides its consumers the ability to compile and execute Arduino sketches on a hosted environment, with bindings to its virtual I/O ports to allow the host application to interact with its child sketches.

Check our [Wiki](https://github.com/ItJustWorksTM/libSMCE/wiki) for more information about usage.

#### Supported I/O
- GPIO (Arduino's `digitalRead`, `analogWrite`, etc)
- UART (Arduino's `Serial` global)
- SD
- MQTT (interface of [arduino-mqtt](https://github.com/256dpi/arduino-mqtt)) - Note: cannot be monitored by host application
- OV767X Camera (interface of [Arduino_OV767X](https://github.com/arduino-libraries/Arduino_OV767X)) - Note: available pixel formats differ

### Build Requirements

- [CMake](https://www.kitware.com/cmake) >= 3.16
- C++20 compiler (tested with [GCC](https://gcc.gnu.org) >= 10, [Clang/LLVM](https://clang.llvm.org) >= 10, MSVC >= 19.28, AppleClang)
- [Boost](https://www.boost.org) >= 1.74 - Not an interface requirement however (you only need Boost headers to build the library, not when using it precompiled) 
- [OpenSSL](https://www.openssl.org) (tested with 1.1.1)

#### Automatically built from source
- [libmosquitto](https://mosquitto.org/api) 2.0.9 - Used for providing MQTT support


### Runtime Requirements
- [CMake](https://www.kitware.com/cmake) >= 3.10
- C++ compiler with support for at least C++11 - MinGW and MSVC-Wine are NOT officially supported
- [ArduinoCLI](https://arduino.github.io/arduino-cli) (**IMPORTANT NOTE**: we use [CMAW](https://github.com/AeroStun/CMAW) to manage ArduinoCLI)

#### Optional
- [Ninja](https://ninja-build.org) - On Un\*x, will be used by setting `CMAKE_GENERATOR` (if that environment variable is unset)

### Build instructions
```shell
cmake -S . -B build
cd build
cmake --build .
```

#### Running the testsuite
```shell
ctest
```

#### Packaging
```shell
cpack
```


### Future development
- Serve the Doxygen-generated docs
- Making a proper [Hugo](https://gohugo.io)-generated wiki in Markdown
- `std::error_code`ify `smce::Board`
- Removal of the strong dependency on ArduinoCLI (preprocess ourselves)
- Add more I/O features, in particular the ones that were in [SMartCarEmul](https://github.com/ItJustWorksTM/SmartcarEmul)
- Add interrupts support
- Allow consumers to specify toolchain files
