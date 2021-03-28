# SMCE-gd ![CI](https://github.com/ItJustWorksTM/smce-gd/workflows/CI/badge.svg)

Official frontend for [libSMCE](https://github.com/ItJustWorksTM/libSMCE) using [Godot](https://godotengine.org/).  
Initially created to emulate cars supporting the [smartcar_shield](https://github.com/platisd/smartcar_shield) platform.

### Resources

* [Releases](https://github.com/ItJustWorksTM/smce-gd/releases)
* [Setup](https://github.com/ItJustWorksTM/smce-gd/wiki)

### Dependencies

* _[Godot](https://godotengine.org)_ (for gdscript)
* _[libSMCE](https://github.com/ItJustWorksTM/libSMCE)_ (prebuilts automatically downloaded)
* _[godot-cpp](https://github.com/godotengine/godot-cpp)_ (automatically built from source; *_SConstruct_ is **not** used, but _Python3_ is still required)
* C++20-compatible compiler + _[CMake](https://cmake.org)_

### Building
```shell
mkdir build
cmake -B build
cmake --build build --target godot-smce
```

Packaging is done using _CPack_.

### Running

* `godot --path project/`
* Or open up the project folder in the _Godot editor_ and start from there.

### Credits

Copyright ItJustWorks™, Apache 2.0 licensed  

Software courtesy of [RuthgerD](https://github.com/RuthgerD)  
CI & Packaging by [AeroStun](https://github.com/AeroStun)  
Logo by [@Reves.sur.papier](https://instagram.com/reves.sur.papier/)  
Car model by [Ancelin Bouchet](https://github.com/anbouchet)  
