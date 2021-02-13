# libSMCE
_Spiritual successor to the backend of SMartCarEmul_

![Build](https://github.com/ItJustWorksTM/libSMCE/workflows/Build/badge.svg?branch=master)

Status: ***EXPERIMENTAL***

### Build Requirements

- CMake >= 3.16
- C++20
- Boost >= 1.74

### Runtime Requirements
- CMake >= 3.?
- ArduinoCLI \[**IMPORTANT NOTE**: if `arduino-cli` cannot be found through your PATH (such as when it is not installed), if Arduino provides a prebuilt package for your system, it will be automatically installed (provided you have an active internet connection) in the resources directory specified when constructing `smce::ExecutionContext`\]