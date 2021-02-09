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

project (godot-smce VERSION 0.0.0 LANGUAGES CXX)

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
list (APPEND GDCPP_NEEDED_CLASSES RayCast Reference Node)
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
target_link_libraries (godot-smce PUBLIC godot-cpp SMCE fmt::fmt)
if (NOT CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    set_target_properties (godot-smce PROPERTIES LINK_FLAGS_RELEASE -s)
endif ()

find_program (GODOT_EXECUTABLE NAMES godot3-headless godot3-server godot3 REQUIRED)
file (MAKE_DIRECTORY "${CMAKE_SOURCE_DIR}/project/gdnative/lib")
add_custom_command (TARGET godot-smce POST_BUILD
        COMMAND "${CMAKE_COMMAND}" -E copy "$<TARGET_FILE:godot-smce>" "${CMAKE_SOURCE_DIR}/project/gdnative/lib/"
        COMMAND "${CMAKE_COMMAND}" -E tar xf "${SMCE_ROOT}/share/SMCE/SMCE_Resources.zip"
        COMMAND "${CMAKE_COMMAND}" -E copy "./RtResources" "./gdnative/lib/"
        COMMAND "${CMAKE_COMMAND}" -E rm -rf "./RtResources"
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/project")

if(WIN32)
    set (GODOT_PLATFORM windows)
elseif(APPLE)
    set (GODOT_PLATFORM macos)
else()
    set (GODOT_PLATFORM linux)
endif()
file (REMOVE_RECURSE "${PROJECT_BINARY_DIR}/export")
file (MAKE_DIRECTORY "${PROJECT_BINARY_DIR}/export")
install (CODE "execute_process (COMMAND \"${GODOT_EXECUTABLE}\" --export \"${GODOT_PLATFORM}\" \"${PROJECT_BINARY_DIR}/export/smce_gd${CMAKE_EXECUTABLE_SUFFIX}\" WORKING_DIRECTORY \"${CMAKE_SOURCE_DIR}/project\")")
install (PROGRAMS "${PROJECT_BINARY_DIR}/export/smce_gd${CMAKE_EXECUTABLE_SUFFIX}" DESTINATION "${CMAKE_INSTALL_LIBDIR}/smce")
install (FILES "${PROJECT_BINARY_DIR}/export/$<TARGET_FILE_NAME:godot-smce>" DESTINATION "${CMAKE_INSTALL_LIBDIR}/smce")

if (NOT SMCE_ARCH)
    set (SMCE_ARCH x86_64)
endif ()
if (CMAKE_CXX_SIMULATE_ID)
    set (SMCE_COMPILER_ID "${CMAKE_CXX_SIMULATE_ID}")
else ()
    set (SMCE_COMPILER_ID "${CMAKE_CXX_COMPILER_ID}")
endif ()
set (CPACK_SYSTEM_NAME "${CMAKE_SYSTEM_NAME}-${SMCE_ARCH}-${SMCE_COMPILER_ID}")
set (CPACK_PACKAGE_NAME "smce_gd")
set (CPACK_PACKAGE_VENDOR "ItJustWorksTM")
set (CPACK_PACKAGE_CONTACT "ItJustWorksTM <itjustworkstm@aerostun.dev>")
set (CPACK_PACKAGE_HOMEPAGE_URL "https://github.com/ItJustWorksTM/smce-gd")
set (CPACK_DEBIAN_PACKAGE_DESCRIPTION "An emulated environment for Arduino-based vehicles; primarily designed for use with the smartcar_shield library.")
set (CPACK_DEBIAN_PACKAGE_SECTION "embedded")
set (CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${PROJECT_SOURCE_DIR}/debian/postinst" "${PROJECT_SOURCE_DIR}/debian/postrm")
set (CPACK_DEBIAN_COMPRESSION_TYPE "xz")
list (APPEND CPACK_GENERATOR ZIP)
if (APPLE)
    list (APPEND CPACK_GENERATOR STGZ)
elseif (NOT WIN32)
    list (APPEND CPACK_GENERATOR STGZ DEB)
endif ()
include (CPack)
