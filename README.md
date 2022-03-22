# SMCE-gd ![CI](https://github.com/ItJustWorksTM/smce-gd/workflows/CI/badge.svg)

Official frontend for [libSMCE](https://github.com/ItJustWorksTM/libSMCE) using [Godot](https://godotengine.org/).  
Initially created to emulate cars supporting the [smartcar_shield](https://github.com/platisd/smartcar_shield) platform.

### Resources

* [Releases](https://github.com/ItJustWorksTM/smce-gd/releases)
* [Setup](https://github.com/ItJustWorksTM/smce-gd/wiki)

### Dependencies

* _[Godot](https://godotengine.org)_
* *_[libSMCE](https://github.com/ItJustWorksTM/libSMCE)_ ([version]([./CMakeLists.txt#L28](https://github.com/ItJustWorksTM/smce-gd/blob/master/CMakeLists.txt#L28)))
* _[godot-cpp](https://github.com/godotengine/godot-cpp)_ (automatically built from source; *_SConstruct_ is **not** used, but _Python3_ is still required)
* C++20-compatible compiler + _[CMake](https://cmake.org)_

\* To install libSMCE head to it's [releases](https://github.com/ItJustWorksTM/libSMCE/releases) page and extract/install one of the artifacts, then set the env var `SMCE_ROOT` pointed to the root of the extracted directory.

### Building
```shell
mkdir build
cmake -B build
cmake --build build --target godot-smce
```

### Building with new LIB_SMCE
Get latest libSMCE Release
Change environment variable to the correct version
copy SMCE.dll from release to project
```shell
cmake --build build --config release
```



Packaging is done using _CPack_.  
_note: we bundle the shared lib of SMCE on export_

### Running

* `godot --path project/`
* Or open up the project folder in the _Godot editor_ and start from there.

### Credits

Copyright ItJustWorks™, Apache 2.0 licensed  

Software courtesy of [RuthgerD](https://github.com/RuthgerD)  
CI & Packaging by [AeroStun](https://github.com/AeroStun)  
Logo by [@Reves.sur.papier](https://instagram.com/reves.sur.papier/)  
Car model by [Ancelin Bouchet](https://github.com/anbouchet)  
