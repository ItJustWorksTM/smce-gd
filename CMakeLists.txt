#
#  CMakeLists.txt
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

cmake_minimum_required (VERSION 3.17)

project (godot-smce LANGUAGES CXX)

set (CMAKE_CXX_STANDARD 20)
set (CMAKE_CXX_STANDARD_REQUIRED ON)
set (CMAKE_CXX_EXTENSIONS OFF)
set (CMAKE_POSITION_INDEPENDENT_CODE ON)

include (CheckIPOSupported)
check_ipo_supported (RESULT CMAKE_IPO_SUPPORTED LANGUAGES CXX)
set (CMAKE_INTERPROCEDURAL_OPTIMIZATION ${CMAKE_IPO_SUPPORTED})

list (APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/CMake/Modules")
set (SMCE_AUTODOWNLOAD True)
include (FetchContent)
include (fmt)
include (SetupSMCE)
include (SetupGodotCpp)

add_library (godot-smce SHARED)
target_sources (godot-smce PRIVATE
        src/lib.cxx
        src/bind/BoardRunner.cxx
        src/bind/ExecutionContext.cxx
        src/bind/BoardView.cxx
        src/virt_devices/AnalogRaycast.cxx
        src/bind/UartSlurper.cxx
        src/virt_devices/BrushedMotor.cxx)
target_include_directories (godot-smce PRIVATE include)
target_link_libraries (godot-smce PUBLIC godot-cpp SMCE fmt::fmt boost_filesystem)
if (NOT CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    set_target_properties (godot-smce PROPERTIES LINK_FLAGS_RELEASE -s)
endif ()

add_custom_command (TARGET godot-smce POST_BUILD
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_SOURCE_DIR}/project/gdnative/lib"
        COMMAND "${CMAKE_COMMAND}" -E copy "$<TARGET_FILE:godot-smce>" "${CMAKE_SOURCE_DIR}/project/gdnative/lib/")

add_custom_command(TARGET godot-smce POST_BUILD
        COMMAND "${CMAKE_COMMAND}" -E tar xf "${SMCE_ROOT}/share/SMCE/SMCE_Resources.zip"
        COMMAND "${CMAKE_COMMAND}" -E copy_directory "${PROJECT_BINARY_DIR}/RtResources" "${CMAKE_SOURCE_DIR}/project/gdnative/lib/RtResources")
