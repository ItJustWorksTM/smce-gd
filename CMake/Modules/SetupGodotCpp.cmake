#
#  SetupGodotCpp.cmake
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

if(NOT GDCPP_ROOT OR NOT EXISTS GDCPP_ROOT)
    set (GDCPP_USER_ROOT "${GDCPP_ROOT}")

    FetchContent_Declare (fc-godot-cpp
            GIT_REPOSITORY https://github.com/godotengine/godot-cpp.git
            GIT_TAG        3.x
            GIT_SHALLOW    1
    )

    FetchContent_GetProperties (fc-godot-cpp)

    if (NOT fc-godot-cpp_POPULATED)
        FetchContent_Populate (fc-godot-cpp)
    endif ()

    set (GDCPP_ROOT "${fc-godot-cpp_SOURCE_DIR}")

    # TODO check sources existence, list sorted equality, and individual timestamps
    set (GDCPP_SOURCES_MOD "${PROJECT_BINARY_DIR}/gdcpp-sources.cmake")
    if (NOT EXISTS "${GDCPP_SOURCES_MOD}")
        file (COPY "${PROJECT_SOURCE_DIR}/binding_generator_ext.py" DESTINATION "${GDCPP_ROOT}")
        message (STATUS "Generating Bindings")
        set (FIRST "")
        foreach (GDCPP_NEEDED_CLASS ${GDCPP_NEEDED_CLASSES})
            string (APPEND GDCPP_NEEDED_CLASSES_FMTD "${FIRST} \"${GDCPP_NEEDED_CLASS}\"")
            set (FIRST ",")
        endforeach ()
        message ("GDCPP_NEEDED_CLASSES_FMTD: ${GDCPP_NEEDED_CLASSES_FMTD}")
        find_package (Python3 REQUIRED COMPONENTS Interpreter)
        execute_process (COMMAND "${Python3_EXECUTABLE}" "-c" "import binding_generator_ext; binding_generator_ext.generate_bindings(\"godot-headers/api.json\", [${GDCPP_NEEDED_CLASSES_FMTD}], False)"
                WORKING_DIRECTORY ${GDCPP_ROOT}
                RESULT_VARIABLE GENERATION_RESULT
                OUTPUT_VARIABLE GENERATION_OUTPUT)
        if (GENERATION_RESULT)
            message (FATAL_ERROR "Bindings generation failed: ${GENERATION_OUTPUT}")
        endif ()

        file (GLOB_RECURSE GDCPP_SOURCES ${GDCPP_ROOT}/src/*.c**)
        file (GLOB_RECURSE GDCPP_HEADERS ${GDCPP_ROOT}/include/*.h**)

        file (WRITE "${GDCPP_SOURCES_MOD}" "add_library (godot-cpp STATIC ")
        foreach (FILE ${GDCPP_SOURCES} ${GDCPP_HEADERS})
            file (APPEND "${GDCPP_SOURCES_MOD}" "\"${FILE}\" ")
        endforeach ()
        file (APPEND "${GDCPP_SOURCES_MOD}" ")")
    endif ()
    add_custom_target (godotcpp-generated DEPENDS "${GDCPP_SOURCES_MOD}")

    include ("${GDCPP_SOURCES_MOD}")

    add_dependencies (godot-cpp godotcpp-generated)

else ()
    add_library (godot-cpp IMPORTED STATIC)
    set_property (TARGET godot-cpp IMPORTED_LOCATION "${GDCPP_ROOT}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}godot-cpp${CMAKE_STATIC_LIBRARY_SUFFIX}")
endif ()

target_include_directories (godot-cpp PUBLIC "${GDCPP_ROOT}/include" "${GDCPP_ROOT}/include/core" "${GDCPP_ROOT}/include/gen")
target_include_directories (godot-cpp SYSTEM PUBLIC "${GDCPP_ROOT}/godot-headers")
