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

cmake_minimum_required(VERSION 3.13)

project(godot-smce LANGUAGES CXX C)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMake/Modules")
include(FetchContent)

include(GodotCpp)
include(SMCE)
include(fmt)

add_library(godot-smce SHARED)

if (UNIX)
    # target_link_options(godot-smce PUBLIC "-s")
endif ()

target_sources(godot-smce PRIVATE
        src/lib.cxx
        src/bind/BoardRunner.cxx
        src/bind/ExecutionContext.cxx
        src/bind/BoardView.cxx
        src/virt_devices/AnalogRaycast.cxx
        src/bind/UartSlurper.cxx)

target_include_directories(godot-smce PRIVATE include)

target_link_libraries(godot-smce PUBLIC godot-cpp SMCE fmt::fmt)

add_custom_command(TARGET godot-smce POST_BUILD
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_SOURCE_DIR}/project/gdnative/lib"
        COMMAND "${CMAKE_COMMAND}" -E copy "$<TARGET_FILE:godot-smce>" "${CMAKE_SOURCE_DIR}/project/gdnative/lib/")

add_custom_command(TARGET godot-smce POST_BUILD
        COMMAND "${CMAKE_COMMAND}" -E tar xf "${libsmce_BINARY_DIR}/SMCE_Resources.zip"
        COMMAND "${CMAKE_COMMAND}" -E copy_directory "${CMAKE_BINARY_DIR}/RtResources" "${CMAKE_SOURCE_DIR}/project/gdnative/lib/RtResources")
