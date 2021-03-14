# SMCE-gd ![CI](https://github.com/ItJustWorksTM/smce-gd/workflows/CI/badge.svg)

Official frontend for [libSMCE](https://github.com/ItJustWorksTM/libSMCE) made with [Godot](https://godotengine.org/)
initially created to emulate virtual cars supporting the [smartcar_shield](https://github.com/platisd/smartcar_shield)
platform.

### Dependencies

* All libSMCE deps
* godot-cpp (Note: we have a custom CMakeFile, SConstruct is **not** used)
* Godot (gdscript)
* C++20 compiler + CMake

### Building

* mkdir build
* cmake -B build
* cmake --build build --target godot-smce

generated .so and RtResources are copied to project/gdnative/lib

### Running

* godot --path project/
* Or open up the project folder in the Godot editor and start from there.

### Exporting

Not a lot of time has been spend on export profiles yet,  
Just make sure `res://gdnative/lib/RtResources/*` is included on export.

Copyright ItJustWorksTM, Apache 2.0 licensed  
Logo by [@Reves.sur.papier](https://instagram.com/reves.sur.papier/)
