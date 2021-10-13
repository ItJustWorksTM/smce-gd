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

### Installation Prerequisites
1. Follow the Wiki Page Set Up to Install Required Bundles depending on your Os:
[Windows](https://github.com/ItJustWorksTM/smce-gd/wiki/Windows-setup) 
[MacOS](https://github.com/ItJustWorksTM/smce-gd/wiki/MacOS-setup)
[Debian-based GNU/Linux](https://github.com/ItJustWorksTM/smce-gd/wiki/Debian-based-Linux-setup))
2. Extract the most up to date libSMCE release, according to your OS:
[libSMCE Releases](https://github.com/ItJustWorksTM/libSMCE/releases) 
3. Set/Update an environment var `SMCE_ROOT` that points to the root of the extracted *libSMCE directory*
4. Restart your PC to make sure the changes have been applied

### Building
```shell
mkdir build
cmake -B build
cmake --build build --target godot-smce
```


Packaging is done using _CPack_.  
_note: we bundle the shared lib of SMCE on export_

### Running

* `godot --path project/`
* Or open up the project folder in the _Godot editor_ and start from there.
* 

### Running on Windows
1. Copy the file `SMCE.dll` from *\build* to *\project\gdnative\lib*
2. Open the terminal and write `godot` to launch the godot editor
    1. Press "Import" and chose the file `project.godot` in *\project*
    2. Launch the project (this needs to be done at least once for the program to work when writing `godot --path project/`)

### Credits

Copyright ItJustWorks™, Apache 2.0 licensed  

Software courtesy of [RuthgerD](https://github.com/RuthgerD)  
CI & Packaging by [AeroStun](https://github.com/AeroStun)  
Logo by [@Reves.sur.papier](https://instagram.com/reves.sur.papier/)  
Car model by [Ancelin Bouchet](https://github.com/anbouchet)  
