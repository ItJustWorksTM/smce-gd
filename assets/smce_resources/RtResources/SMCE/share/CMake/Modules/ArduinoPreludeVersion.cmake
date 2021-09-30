#
#  ArduinoPreludeVersion.cmake
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

## Expected variables:
# ARDPRE_EXECUTABLE - location of the arduino-prelude executable

execute_process (COMMAND "${ARDPRE_EXECUTABLE}" --version
    RESULT_VARIABLE ARDPRE_VERSION_COMMAND_RESULT
    OUTPUT_VARIABLE ARDPRE_VERSION_COMMAND_OUTPUT
)
if (ARDPRE_VERSION_COMMAND_RESULT)
  message (FATAL_ERROR "Query for arduino-prelude version failed (${ARDPRE_VERSION_COMMAND_RESULT})")
endif ()

if ("${ARDPRE_VERSION_COMMAND_OUTPUT}" MATCHES "^arduino-prelude v([0-9]+\\.[0-9]+\\.[0-9]+)\n\r?$")
  set (ARDPRE_VERSION "${CMAKE_MATCH_1}")
  message (STATUS "Found arduino-prelude v${ARDPRE_VERSION}")
else ()
  message (FATAL_ERROR "Unable to determine arduino-prelude version:\n${ARDPRE_VERSION_COMMAND_OUTPUT}")
endif ()
