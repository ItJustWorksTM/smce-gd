#
#  CMakeLists.txt
#  Copyright 2020 ItJustWorksTM
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

cmake_minimum_required(VERSION 3.17)

project(godot-smce LANGUAGES CXX C)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if (WIN32)
    set(SCONS_PLATFORM windows)
elseif (UNIX AND NOT APPLE)
    set(SCONS_PLATFORM linux)
elseif (APPLE)
    set(SCONS_PLATFORM osx)
else ()
    message(FATAL_ERROR "Platform not supported")
endif ()

set(SCONS_TARGET "debug")
if (CMAKE_BUILD_TYPE STREQUAL Release)
    set(SCONS_TARGET "release")
endif ()

set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)

set(GODOTCPP_TARGET ${CMAKE_SOURCE_DIR}/thirdparty/godot-cpp/bin/libgodot-cpp.${SCONS_PLATFORM}.${SCONS_TARGET}.64${CMAKE_STATIC_LIBRARY_SUFFIX})
add_custom_command(OUTPUT ${GODOTCPP_TARGET}
        COMMAND scons --cache-force -C ${CMAKE_SOURCE_DIR}/thirdparty/godot-cpp platform=${SCONS_PLATFORM} target=${SCONS_TARGET} generate_bindings=yes -j8)

add_custom_target(gotdot-cpp-proxygen DEPENDS ${GODOTCPP_TARGET})

add_library(godot-cpp INTERFACE)
target_include_directories(godot-cpp INTERFACE
        thirdparty/godot-cpp/godot_headers
        thirdparty/godot-cpp/include
        thirdparty/godot-cpp/include/core
        thirdparty/godot-cpp/include/gen)

target_link_libraries(godot-cpp INTERFACE ${GODOTCPP_TARGET})

if (UNIX)
    target_link_options(godot-cpp INTERFACE "-s")
endif ()

add_library(godot-smce SHARED)

target_sources(godot-smce PRIVATE src/lib.cxx src/Dummy.cxx)
target_include_directories(godot-smce PRIVATE include)
add_dependencies(godot-cpp gotdot-cpp-proxygen)

target_link_libraries(godot-smce godot-cpp)

add_custom_command(TARGET godot-smce POST_BUILD
        COMMAND "${CMAKE_COMMAND}" -E copy "$<TARGET_FILE:godot-smce>" "${CMAKE_SOURCE_DIR}/project/gdnative/lib/"
        COMMAND "echo" "copied to: $<TARGET_FILE:godot-smce>  ${CMAKE_SOURCE_DIR}/project/gdnative/lib/ ")