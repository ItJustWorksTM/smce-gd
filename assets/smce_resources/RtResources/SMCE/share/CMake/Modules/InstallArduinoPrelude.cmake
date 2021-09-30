#
#  InstallArduinoPrelude.cmake
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
# ARDPRE_ROOT - root directory of the arduino-prelude install tree

set (ARDPRE_KNOWN_LATEST "1.0.1")

# Compute archive filename
set (ARDPRE_FILENAME_SYS "${CMAKE_HOST_SYSTEM_NAME}")
if (WIN32)
  if ("${CMAKE_HOST_SYSTEM_PROCESSOR}" MATCHES "64")
    set (ARDPRE_FILENAME_SYS win64)
  else()
    set (ARDPRE_FILENAME_SYS win32)
  endif()
endif ()
set (ARDPRE_DL_FILENAME "arduino-prelude-${ARDPRE_KNOWN_LATEST}-${ARDPRE_FILENAME_SYS}")

# Compute download URI
set (ARDPRE_DL_STEM "https://github.com/ItJustWorksTM/arduino-prelude/releases")
if (WIN32)
  if ("${CMAKE_HOST_SYSTEM_PROCESSOR}" STREQUAL "AMD64" OR "${CMAKE_HOST_SYSTEM_PROCESSOR}" STREQUAL "IA64")
    set (ARDPRE_DL_URI "${ARDPRE_DL_STEM}/download/v${ARDPRE_KNOWN_LATEST}/${ARDPRE_DL_FILENAME}.zip")
  endif ()
elseif (APPLE)
  # We'll assume we never run on iOS, watchOS, or tvOS, nor on a PPC OSX
  set (ARDPRE_DL_URI "${ARDPRE_DL_STEM}/download/v${ARDPRE_KNOWN_LATEST}/${ARDPRE_DL_FILENAME}.tar.gz")
elseif ("${CMAKE_HOST_SYSTEM_NAME}" STREQUAL "Linux" AND "${CMAKE_HOST_SYSTEM_PROCESSOR}" STREQUAL "x86_64")
  set (ARDPRE_DL_URI "${ARDPRE_DL_STEM}/download/v${ARDPRE_KNOWN_LATEST}/${ARDPRE_DL_FILENAME}.tar.gz")
endif ()

if (NOT DEFINED ARDPRE_DL_URI)
  message (FATAL_ERROR "Unsupported system for arduino-prelude automatic download; please install it manually")
endif ()

file (MAKE_DIRECTORY "${ARDPRE_ROOT}")
set (ARDPRE_ARK_EXT ".tgz")
if (WIN32)
  set (ARDPRE_ARK_EXT ".zip")
endif ()
set (ARDPRE_ARK "${ARDPRE_ROOT}/arduino-prelude${ARDPRE_ARK_EXT}")
message (STATUS "Downloading arduino-prelude")
file (DOWNLOAD "${ARDPRE_DL_URI}" "${ARDPRE_ARK}")
if (NOT EXISTS "${ARDPRE_ARK}")
  message (FATAL_ERROR "Failed to download arduino-prelude; do you have an active internet connection?")
endif ()
execute_process (COMMAND "${CMAKE_COMMAND}" -E tar xf "${ARDPRE_ARK}"
    WORKING_DIRECTORY "${ARDPRE_ROOT}"
)
file (REMOVE "${ARDPRE_ARK}")
file (RENAME "${ARDPRE_ROOT}/${ARDPRE_DL_FILENAME}" "${ARDPRE_ROOT}/bin")
set (ARDPRE_EXECUTABLE "${ARDPRE_ROOT}/bin/arduino-prelude${CMAKE_EXECUTABLE_SUFFIX}")
