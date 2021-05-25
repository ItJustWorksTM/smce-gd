#
#  Runtime/CMakeLists.txt
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
# SKETCH_DIR - Path to the sketch

cmake_minimum_required (VERSION 3.10)

project (Sketch CXX)

foreach (CXX_COMPILE_FEATURE ${CMAKE_CXX_COMPILE_FEATURES})
    if (CXX_COMPILE_FEATURE MATCHES "cxx_std_([0-8][0-9]+)")
        list (APPEND CXX_SUPPORTED_VERSIONS "${CMAKE_MATCH_1}")
    endif ()
endforeach ()
list (SORT CXX_SUPPORTED_VERSIONS)
list (REVERSE CXX_SUPPORTED_VERSIONS)
list (GET CXX_SUPPORTED_VERSIONS 1 CXX_HIGHEST_SUPPORTED_VERSION)
set (CMAKE_CXX_STANDARD "${CXX_HIGHEST_SUPPORTED_VERSION}")
message ("Using CMAKE_CXX_STANDARD: ${CMAKE_CXX_STANDARD}")

include ("${SMCE_DIR}/RtResources/Ardrivo/share/ArdrivoOutputNames.cmake")
add_library (Ardrivo SHARED IMPORTED)
target_include_directories (Ardrivo SYSTEM INTERFACE "${SMCE_DIR}/RtResources/Ardrivo/include/Ardrivo")
target_compile_definitions (Ardrivo INTERFACE "__SMCE__=1")
target_compile_features (Ardrivo INTERFACE cxx_std_11)
set_property (TARGET Ardrivo PROPERTY IMPORTED_LOCATION "${SMCE_DIR}/RtResources/Ardrivo/bin/${ARDRIVO_FILE_NAME}")
set_property (TARGET Ardrivo PROPERTY IMPORTED_IMPLIB "${SMCE_DIR}/RtResources/Ardrivo/bin/${ARDRIVO_LINKER_FILE_NAME}")

if (MSVC)
    target_compile_options (Ardrivo INTERFACE "/permissive-" "/W4" "/w34265" "/w44289" "/w44296" "/w14545" "/w14546" "/w14547" "/w14548" "/w14549" "/w14555" "/w44574" "/w44582" "/w44583" "/w34619" "/w44749" "/w44777" "/w44837" "/w44841" "/w44842" "/w14928" "/w14946" "/w44986" "/w44987" "/w45022" "/w45023" "/w45029" "/w45038" "/wd4250")
else ()
    target_compile_options (Ardrivo INTERFACE "-Wpedantic" "-Wall" "-Wextra" "-Wnon-virtual-dtor" "-Wold-style-cast" "-Wcast-align" "-Woverloaded-virtual" "-Wnull-dereference")
endif ()

if (WIN32)
    file (CREATE_LINK "${SMCE_DIR}/RtResources/Ardrivo/bin/${ARDRIVO_FILE_NAME}"
            "${PROJECT_BINARY_DIR}/${ARDRIVO_FILE_NAME}" COPY_ON_ERROR SYMBOLIC)
endif ()

add_executable (Sketch)
target_sources (Sketch PRIVATE "${PROJECT_SOURCE_DIR}/sketch.cpp" "${SMCE_DIR}/RtResources/Ardrivo/share/sketch_main.cpp")
target_include_directories (Sketch PRIVATE "${SKETCH_DIR}")
target_link_libraries (Sketch Ardrivo)
target_compile_definitions (Sketch PUBLIC SMCE__COMPILING_USERCODE=1)
add_custom_command (TARGET Sketch POST_BUILD COMMAND "${CMAKE_COMMAND}" -E rename "$<TARGET_FILE:Sketch>" "${PROJECT_BINARY_DIR}/Sketch")
file (GLOB CXX_SOURCES LIST_DIRECTORIES false "${SKETCH_DIR}/*.cpp" "${SKETCH_DIR}/*.cxx" "${SKETCH_DIR}/*.cc" "${SKETCH_DIR}/*.c++")
target_sources (Sketch PRIVATE ${CXX_SOURCES})

file (GLOB LIBS LIST_DIRECTORIES true "${PROJECT_SOURCE_DIR}/libs/*")
foreach (LIB ${LIBS})
    if (${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.20")
        cmake_path (GET LIB FILENAME LIB_NAME)
    else ()
        get_filename_component (LIB_NAME "${LIB}" NAME)
    endif ()
    file (GLOB_RECURSE LIB_SOURCES LIST_DIRECTORIES false "${LIB}/src/*")
    if (NOT LIB_SOURCES)
        message (FATAL_ERROR "No sources found for library \"${LIB_NAME}\" (at \"${LIB}\")")
    endif ()

    add_library ("${LIB_NAME}" OBJECT ${LIB_SOURCES})
    target_include_directories ("${LIB_NAME}" PUBLIC "${LIB}/src")
    target_link_libraries ("${LIB_NAME}" PUBLIC Ardrivo)

    if (${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.12")
        target_link_libraries (Sketch "${LIB_NAME}")
    else ()
        target_sources (Sketch $<TARGET_OBJECTS:${LIB_NAME}>)
    endif ()
endforeach ()
