/*
 *  SketchConf.hpp
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

#ifndef SMCE_SKETCHCONF_HPP
#define SMCE_SKETCHCONF_HPP

#include <string>
#include <variant>
#include <vector>
#include <SMCE/fwd.hpp>
#include <SMCE/SMCE_fs.hpp>

namespace smce {

/**
 * Configuration for sketch building
 **/
struct SketchConfig {
    /**
     * On-disk C++ library
     * \warning Unused; unsupported at the current time
     **/
    struct FreestandingLibrary {
        stdfs::path include_dir; /// Include directory for that library
        stdfs::path archive_path;  /// Path to that library's binary; empty if none
        std::vector<std::string> compile_defs;  /// Arguments to CMake's target_compile_definitions
    };
    /**
     * Library to pull from the Arduino library manager
     **/
    struct RemoteArduinoLibrary {
        std::string name; // Library name as found in the install command
        std::string version; // Version string; empty if latest
    };
    /**
     * On-disk Arduino-layout library
     *
     * Can also be a patch for a remote library, in which case both
     * file trees will be merged, with the patch taking priority.
     **/
    struct LocalArduinoLibrary {
        stdfs::path root_dir; // Root directory of the library
        std::string patch_for; // Name of the remote library being patched; none if not patching
    };
    using Library = std::variant<FreestandingLibrary, RemoteArduinoLibrary, LocalArduinoLibrary>;
    std::vector<std::string> extra_board_uris; /// Extra board.txt URIs for ArduinoCLI
    std::vector<Library> preproc_libs; /// Libraries to use during preprocessing
    std::vector<Library> complink_libs; /// Libraries to use at compile and link time
    std::vector<std::string> extra_compile_defs; /// Arguments to CMake's target_compile_definitions
    std::vector<std::string> extra_compile_opts; /// Arguments to CMake's target_compile_options
};

}

#endif // SMCE_SKETCHCONF_HPP
