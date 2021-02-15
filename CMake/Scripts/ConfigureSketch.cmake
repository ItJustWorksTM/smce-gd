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
cmaw_install_libraries (MQTT)

string (RANDOM LENGTH 13 COMP_DIRNAME)
set (COMP_DIR "${SMCE_DIR}/tmp/${COMP_DIRNAME}")
file (MAKE_DIRECTORY "${COMP_DIR}")
message (STATUS "SMCE: Compilation directory is \"${COMP_DIR}\"")

cmaw_preprocess (PREPROCD_SKETCH "${SKETCH_FQBN}" "${SKETCH_PATH}")
set (COMP_SRC "${COMP_DIR}/sketch.cpp")
file (WRITE "${COMP_SRC}" "${PREPROCD_SKETCH}")

file (COPY "${SMCE_DIR}/RtResources/SMCE/share/Runtime/CMakeLists.txt" DESTINATION "${COMP_DIR}")
file (MAKE_DIRECTORY "${COMP_DIR}/build")
execute_process (COMMAND "${CMAKE_COMMAND}" "-DSMCE_DIR=${SMCE_DIR}" -S "${COMP_DIR}" -B "${COMP_DIR}/build")

message (STATUS "SMCE: Sketch binary will be at \"${COMP_DIR}/build/Sketch\"")
