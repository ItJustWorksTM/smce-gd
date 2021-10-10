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

project (smce-gd VERSION 1.4.0 LANGUAGES CXX)

set (CMAKE_CXX_STANDARD 20)
set (CMAKE_CXX_STANDARD_REQUIRED ON)
set (CMAKE_CXX_EXTENSIONS OFF)
set (CMAKE_POSITION_INDEPENDENT_CODE ON)

find_package(Threads REQUIRED)
find_package(SMCE 1.3.0 REQUIRED)

include (CheckIPOSupported)
check_ipo_supported (RESULT CMAKE_IPO_SUPPORTED LANGUAGES CXX)
set (CMAKE_INTERPROCEDURAL_OPTIMIZATION ${CMAKE_IPO_SUPPORTED})

list (APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/CMake/Modules")

set (SMCE_AUTODOWNLOAD True)
include (FetchContent)

list (APPEND GDCPP_NEEDED_CLASSES Reference)
include (SetupGodotCpp)



add_library (smce-gd MODULE)
target_sources (smce-gd PRIVATE
        src/lib.cxx
        src/types/bind/board/Board.cxx
        src/types/bind/board/BoardConfig.cxx
        src/types/bind/board/BoardDeviceSpec.cxx
        src/types/bind/sketch/Toolchain.cxx
        src/types/bind/sketch/Sketch.cxx
        src/types/bind/sketch/SketchConfig.cxx
        src/types/bind/board_view/BoardView.cxx
        src/types/bind/board_view/UartChannel.cxx
        src/types/bind/board_view/GpioPin.cxx
        src/types/bind/board_view/FrameBuffer.cxx
        src/types/bind/board_view/DynamicBoardDevice.cxx
        src/types/sync/Channel.cxx
        src/types/sync/Future.cxx)

target_include_directories (smce-gd PUBLIC src/)
target_link_libraries (smce-gd PUBLIC godot-cpp SMCE::SMCE)
if (NOT CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    set_target_properties (smce-gd PROPERTIES LINK_FLAGS_RELEASE -s)
    if (NOT APPLE AND CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        target_link_options (smce-gd PRIVATE -static-libstdc++ -static-libgcc)
    endif ()
endif ()

get_target_property (SMCE_RT_RES SMCE::SMCE RESOURCES_ARCHIVE)

find_program (GODOT_EXECUTABLE NAMES godot3-headless godot3-server godot3 godot REQUIRED)
add_custom_command (TARGET smce-gd POST_BUILD
        COMMAND "${CMAKE_COMMAND}" -E copy "$<TARGET_FILE:smce-gd>" "${PROJECT_SOURCE_DIR}/assets/native/lib/"
        COMMAND "${CMAKE_COMMAND}" -E tar xf "${SMCE_RT_RES}"
        WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}/assets/smce_resources"
)

include (CPackPackaging)