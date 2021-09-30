#
#  Preprocessing.cmake
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
# ARDPRE_EXECUTABLE - Path of the arduino-prelude executable
# SKETCH_DIR - Path to the sketch

## Expected targets:
# Sketch - sketch executable target

## File outputs:
# "${PROJECT_SOURCE_DIR}/sketch.cpp"

if (CMAKE_SCRIPT_MODE_FILE)
  message (FATAL_ERROR "This module may only be included in a CMake project configuration")
endif ()

message (STATUS "Setting up preprocessing harness")

set (INCLUDE_DIRS)
set (COMP_DEFS)

get_target_property (SKETCH_INCLUDE_DIRS Sketch INCLUDE_DIRECTORIES)
list (APPEND INCLUDE_DIRS ${SKETCH_INCLUDE_DIRS})

get_target_property (SKETCH_COMP_DEFS Sketch COMPILE_DEFINITIONS)
list (APPEND COMP_DEFS ${SKETCH_COMP_DEFS})

include (ProbeCompilerIncdirs)
list (APPEND INCLUDE_DIRS ${COMPILER_INCLUDE_DIRS})

get_target_property (SKETCH_LINK_LIBS Sketch LINK_LIBRARIES)
foreach (LIB ${SKETCH_LINK_LIBS})
  if (NOT TARGET "${LIB}")
    continue ()
  endif ()
  get_target_property (LIB_INCLUDE_DIRS "${LIB}" INCLUDE_DIRECTORIES)
  if (LIB_INCLUDE_DIRS)
    list (APPEND INCLUDE_DIRS ${LIB_INCLUDE_DIRS})
  endif ()
  get_target_property (LIB_COMP_DEFS "${LIB}" COMPILE_DEFINITIONS)
  if (LIB_COMP_DEFS)
    list (APPEND COMP_DEFS ${LIB_COMP_DEFS})
  endif ()
  get_target_property (LIB_INCLUDE_DIRS "${LIB}" INTERFACE_INCLUDE_DIRECTORIES)
  if (LIB_INCLUDE_DIRS)
    list (APPEND INCLUDE_DIRS ${LIB_INCLUDE_DIRS})
  endif ()
  get_target_property (LIB_COMP_DEFS "${LIB}" INTERFACE_COMPILE_DEFINITIONS)
  if (LIB_COMP_DEFS)
    list (APPEND COMP_DEFS ${LIB_COMP_DEFS})
  endif ()
endforeach ()

set (INCDIR_FLAGS "")
foreach (INCDIR ${INCLUDE_DIRS})
  string (APPEND INCDIR_FLAGS " \"-I${INCDIR}\"")
endforeach ()
string (REPLACE "\\" "\\\\" INCDIR_FLAGS "${INCDIR_FLAGS}")

set (COMPDEF_FLAGS "")
foreach (COMPDEF ${COMP_DEFS})
  string (APPEND COMPDEF_FLAGS " \"-D${COMPDEF}\"")
endforeach ()
string (REPLACE "\\" "\\\\" COMPDEF_FLAGS "${COMPDEF_FLAGS}")

set (EXTRA_FLAGS "-std=c++${CMAKE_CXX_STANDARD}")
if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
  set (EXTRA_FLAGS "-std=gnu++${CMAKE_CXX_STANDARD}")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "AppleClang")
  string (APPEND EXTRA_FLAGS " -I${CMAKE_OSX_SYSROOT}/usr/include")
elseif (MSVC)
  string (APPEND EXTRA_FLAGS " -fms-extensions")
endif ()

string (APPEND EXTRA_FLAGS " -nostdinc -nostdinc++ -include Arduino.h")

file (WRITE "${PROJECT_BINARY_DIR}/ArduinoSourceBuild.cmake" "execute_process (COMMAND \"${ARDPRE_EXECUTABLE}\" \"${SKETCH_DIR}\" ${COMPDEF_FLAGS} ${INCDIR_FLAGS} ${EXTRA_FLAGS} ${CMAKE_CXX_FLAGS} RESULT_VARIABLE ARDPRE_EXITCODE OUTPUT_FILE \"${PROJECT_SOURCE_DIR}/sketch.cpp\")\n")
file (APPEND "${PROJECT_BINARY_DIR}/ArduinoSourceBuild.cmake" [[
    if (ARDPRE_EXITCODE)
      message (FATAL_ERROR "Preprocessing failed: ${ARDPRE_EXITCODE}")
    endif ()
]])

set (SKETCH_SOURCE_FILES)
file (GLOB SKETCH_SOURCE_FILES LIST_DIRECTORIES false CONFIGURE_DEPENDS "${SKETCH_DIR}/*.ino" "${SKETCH_DIR}/*.pde")

add_custom_command (OUTPUT "${PROJECT_SOURCE_DIR}/sketch.cpp"
    COMMAND "${CMAKE_COMMAND}" -E env ARDUINO_PRELUDE_DUMP_COMPOSITE=1 "${CMAKE_COMMAND}" -P "${PROJECT_BINARY_DIR}/ArduinoSourceBuild.cmake"
    DEPENDS ${SKETCH_SOURCE_FILES}
    COMMENT "Preprocessing sketch \"${SKETCH_DIR}\""
)
