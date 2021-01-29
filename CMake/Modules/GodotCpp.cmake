#
#  GodotCpp.cmake
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

add_library(godot-cpp STATIC)

FetchContent_Declare(godot-cppy
        GIT_REPOSITORY https://github.com/portaloffreedom/godot-cpp.git
        GIT_TAG cmake-gen-fix
        )

FetchContent_GetProperties(godot-cppy)

if (NOT godot-cppy_POPULATED)
    FetchContent_Populate(godot-cppy)
endif ()

set(GODOTSRC ${godot-cppy_SOURCE_DIR})
set(GODOTBIN ${godot-cppy_BINARY_DIR})

set(GODOT_API ${GODOTSRC}/godot_headers/api.json)

execute_process(COMMAND "python" "-c" "import binding_generator; binding_generator.print_file_list(\"${GODOT_API}\", \"${GODOTBIN}\", headers=True)"
        WORKING_DIRECTORY ${GODOTSRC}
        OUTPUT_VARIABLE GEN_HEADER)

set(GEN_HEADER ${GEN_HEADER})

execute_process(COMMAND "python" "-c" "import binding_generator; binding_generator.print_file_list(\"${GODOT_API}\", \"${GODOTBIN}\", sources=True)"
        WORKING_DIRECTORY ${GODOTSRC}
        OUTPUT_VARIABLE GEN_SOURCES)

set(GEN_SOURCES ${GEN_SOURCES})

add_custom_command(OUTPUT ${GEN_HEADERS} ${GEN_SOURCES}
        COMMAND "python" "-c" "import binding_generator; binding_generator.generate_bindings('${GODOT_API}', False, '${GODOTBIN}')"
        VERBATIM
        WORKING_DIRECTORY ${GODOTSRC}
        MAIN_DEPENDENCY ${GODOT_API}
        DEPENDS ${GODOTSRC}/binding_generator.py
        COMMENT Generating Bindings)

set(SOURCES AABB.cpp
        Array.cpp
        Basis.cpp
        CameraMatrix.cpp
        Color.cpp
        Dictionary.cpp
        GodotGlobal.cpp
        NodePath.cpp Plane.cpp
        PoolArrays.cpp
        Quat.cpp
        Rect2.cpp
        RID.cpp
        String.cpp
        TagDB.cpp
        Transform.cpp
        Transform2D.cpp
        Variant.cpp
        Vector2.cpp
        Vector3.cpp)

set(HEADERS include
        include/core
        godot_headers)

list(TRANSFORM SOURCES PREPEND "${GODOTSRC}/src/core/" OUTPUT_VARIABLE PSOURCES)
list(TRANSFORM HEADERS PREPEND "${GODOTSRC}/" OUTPUT_VARIABLE PHEADERS)

target_compile_options(godot-cpp PRIVATE "-Wno-unused-parameter" "-Wno-absolute-value")

target_sources(godot-cpp PRIVATE ${PSOURCES} ${GEN_SOURCES})
target_include_directories(godot-cpp PUBLIC ${PHEADERS} ${GODOTBIN}/include ${GODOTBIN}/include/gen)
