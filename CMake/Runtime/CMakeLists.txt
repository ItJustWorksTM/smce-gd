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

cmake_minimum_required (VERSION 3.10)

project (Sketch)

include ("${SMCE_DIR}/RtResources/Ardrivo/share/ArdrivoOutputNames.cmake")
add_library (Ardrivo SHARED IMPORTED)
target_include_directories (Ardrivo INTERFACE "${SMCE_DIR}/RtResources/Ardrivo/include/Ardrivo")
target_compile_definitions (Ardrivo INTERFACE "__SMCE__=1")
set_property (TARGET Ardrivo PROPERTY IMPORTED_LOCATION "${SMCE_DIR}/RtResources/Ardrivo/bin/${ARDRIVO_FILE_NAME}")
set_property (TARGET Ardrivo PROPERTY IMPORTED_IMPLIB "${SMCE_DIR}/RtResources/Ardrivo/bin/${ARDRIVO_LINKER_FILE_NAME}")

if (WIN32)
    file (CREATE_LINK "${SMCE_DIR}/RtResources/Ardrivo/bin/${ARDRIVO_FILE_NAME}"
            "${PROJECT_BINARY_DIR}/${ARDRIVO_FILE_NAME}" COPY_ON_ERROR SYMBOLIC)
endif ()

add_executable (Sketch)
target_compile_features (Sketch PUBLIC cxx_std_11)
target_sources (Sketch PRIVATE "${PROJECT_SOURCE_DIR}/sketch.cpp" "${SMCE_DIR}/RtResources/Ardrivo/share/sketch_main.cpp")
target_link_libraries (Sketch Ardrivo)
target_compile_definitions(Sketch PUBLIC SMCE__COMPILING_USERCODE=1)
add_custom_command (TARGET Sketch POST_BUILD COMMAND "${CMAKE_COMMAND}" -E rename "$<TARGET_FILE:Sketch>" "${PROJECT_BINARY_DIR}/Sketch")

file (GLOB LIBS LIST_DIRECTORIES true "${PROJECT_SOURCE_DIR}/libs/*")
foreach (LIB ${LIBS})
    if (${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.20")
        cmake_path (GET "${LIB}" FILENAME LIB_NAME)
    else ()
        get_filename_component (LIB_NAME "${LIB}" NAME)
    endif()
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
    endif()
endforeach ()
