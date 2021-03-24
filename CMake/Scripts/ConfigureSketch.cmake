#
#  ConfigureSketch.cmake
#  Copyright 2021 ItJustWorksTM
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

## Expected variables
# SMCE_DIR - Path to the SMCE dir
# SKETCH_FQBN - Fully qualified board name to use
# SKETCH_PATH - Path to the Arduino sketch
# PREPROC_REMOTE_LIBS - whitespace-separated of remote libs to pull for preprocessing
# COMPLINK_REMOTE_LIBS - remote libs needed at compile/link-time
# COMPLINK_PATCH_LIBS - remote libs to patch for compile/link-time

cmake_policy (SET CMP0011 NEW)

set (MODULES_DIR "${SMCE_DIR}/RtResources/CMake/Modules")
list (APPEND CMAKE_MODULE_PATH "${MODULES_DIR}")

# Download latest CMAW if not preinstalled
set (CMAW_URL "https://github.com/AeroStun/CMAW/raw/master/CMAW.cmake")
set (CMAW_RUNLOC "${MODULES_DIR}/CMAW.cmake")
if (NOT EXISTS "${MODULES_DIR}")
    file (MAKE_DIRECTORY "${MODULES_DIR}")
    file (DOWNLOAD "${CMAW_URL}" "${CMAW_RUNLOC}")
endif ()
set (CMAW_AUTO_PATH "${SMCE_DIR}")
include (CMAW)

message (STATUS "Using CMAW version ${CMAW_VERSION}")

cmaw_arduinocli_version (ARDCLI_VERSION)
message (STATUS "Using ArduinoCLI version ${ARDCLI_VERSION}")

string (REPLACE ":" ";" SKETCH_FQBN_PARTS ${SKETCH_FQBN})
list (GET SKETCH_FQBN_PARTS 0 SKETCH_FQBN_PACKAGER)
list (GET SKETCH_FQBN_PARTS 1 SKETCH_FQBN_ARCH)
cmaw_install_cores ("${SKETCH_FQBN_PACKAGER}:${SKETCH_FQBN_ARCH}")
cmaw_update_library_index ()
foreach (REMOTE_LIB ${PREPROC_REMOTE_LIBS} ${COMPLINK_REMOTE_LIBS})
    cmaw_install_libraries ("${REMOTE_LIB}")
endforeach ()

cmaw_dump_config (ARDCLI_CONFIG)
string (REGEX REPLACE ";" "\\\\;" ARDCLI_CONFIG "${ARDCLI_CONFIG}")
string (REGEX REPLACE "\n" ";" ARDCLI_CONFIG "${ARDCLI_CONFIG}")
set (ARDCLI_CONFIG_USERDIR "NOTFOUND")
foreach (ARDCLI_CONFIG_LINE ${ARDCLI_CONFIG})
    if (ARDCLI_CONFIG_LINE MATCHES "^  user: (.*)$")
        string (STRIP "${CMAKE_MATCH_1}" ARDCLI_CONFIG_USERDIR)
        break ()
    endif ()
endforeach ()
if (NOT ARDCLI_CONFIG_USERDIR)
    message (FATAL_ERROR "Could not find the userdir in the ArduinoCLI config dump")
elseif (NOT EXISTS "${ARDCLI_CONFIG_USERDIR}")
    message (WARNING "ArduinoCLI userdir could not be found on disk (\"${ARDCLI_CONFIG_USERDIR}\")")
endif ()

string (RANDOM LENGTH 13 COMP_DIRNAME)
set (COMP_DIR "${SMCE_DIR}/tmp/${COMP_DIRNAME}")
file (MAKE_DIRECTORY "${COMP_DIR}")
message (STATUS "SMCE: Compilation directory is \"${COMP_DIR}\"")

file (MAKE_DIRECTORY "${COMP_DIR}/libs")
foreach (COMPLINK_PATCH_LIB ${COMPLINK_PATCH_LIBS})
    string (REGEX MATCH "^([^|]+)\\|([^@]*)(@?[0-9.]*)$" MATCH "${COMPLINK_PATCH_LIB}")
    if(NOT MATCH)
        message (FATAL_ERROR "Invalid COMPLINK_PATCH_LIB (\"${COMPLINK_PATCH_LIB}\")")
    endif ()
    set (COMPLINK_PATCH_LIB_PATH "${CMAKE_MATCH_1}")
    string (REPLACE " " "_" COMPLINK_PATCH_LIB_TARGET "${CMAKE_MATCH_2}")

    message (STATUS "Processing library \"${COMPLINK_PATCH_LIB_TARGET}\" (patched by \"${COMPLINK_PATCH_LIB_PATH}\")")
    # Copy original library
    file (COPY "${ARDCLI_CONFIG_USERDIR}/libraries/${COMPLINK_PATCH_LIB_TARGET}" DESTINATION "${COMP_DIR}/libs")

    # Merge-in the patch tree
    file (GLOB_RECURSE COMPLINK_PATCH_LIB_FILEPATHS
            LIST_DIRECTORIES false RELATIVE "${COMPLINK_PATCH_LIB_PATH}"
            "${COMPLINK_PATCH_LIB_PATH}/*")
    foreach (COMPLINK_PATCH_LIB_RELFILEPATH ${COMPLINK_PATCH_LIB_FILEPATHS})
        if(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.20")
            cmake_path (GET COMPLINK_PATCH_LIB_RELFILEPATH PARENT_PATH COMPLINK_PATCH_LIB_RELFILEDIR)
        else ()
            get_filename_component (COMPLINK_PATCH_LIB_RELFILEDIR "${COMPLINK_PATCH_LIB_RELFILEPATH}" DIRECTORY)
        endif()
        file (MAKE_DIRECTORY "${COMP_DIR}/libs/${COMPLINK_PATCH_LIB_TARGET}/${COMPLINK_PATCH_LIB_RELFILEDIR}")
        file (COPY "${COMPLINK_PATCH_LIB_PATH}/${COMPLINK_PATCH_LIB_RELFILEPATH}" DESTINATION "${COMP_DIR}/libs/${COMPLINK_PATCH_LIB_TARGET}/${COMPLINK_PATCH_LIB_RELFILEDIR}")
    endforeach ()
endforeach ()

cmaw_preprocess (PREPROCD_SKETCH "${SKETCH_FQBN}" "${SKETCH_PATH}")
if ("${PREPROCD_SKETCH}" STREQUAL "")
    message (FATAL_ERROR "Preprocessing failed")
endif ()
set (COMP_SRC "${COMP_DIR}/sketch.cpp")
file (WRITE "${COMP_SRC}" "${PREPROCD_SKETCH}")

file (COPY "${SMCE_DIR}/RtResources/SMCE/share/Runtime/CMakeLists.txt" DESTINATION "${COMP_DIR}")
file (MAKE_DIRECTORY "${COMP_DIR}/build")
execute_process (COMMAND "${CMAKE_COMMAND}" "-DSMCE_DIR=${SMCE_DIR}" -S "${COMP_DIR}" -B "${COMP_DIR}/build")

message (STATUS "SMCE: Sketch binary will be at \"${COMP_DIR}/build/Sketch\"")
