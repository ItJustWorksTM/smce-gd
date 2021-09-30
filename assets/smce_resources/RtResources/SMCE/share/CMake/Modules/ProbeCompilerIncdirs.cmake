#
#  ProbeCompilerIncdirs.cmake
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

if (CMAKE_SCRIPT_MODE_FILE)
  message (FATAL_ERROR "This module may only be included in a CMake project configuration")
endif ()

set (COMPILER_INCLUDE_DIRS)

file (WRITE "${PROJECT_BINARY_DIR}/empty" "")
if (MSVC AND NOT CMAKE_CXX_SIMULATE_ID)
  # FIXME - Handle VS < 2015 as well as Windows < 10

  list (GET CMAKE_CXX_COMPILER 0 CL_EXECUTABLE)
  if (${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.20")
    cmake_path (GET CL_EXECUTABLE PARENT_PATH CL_BINDIR)
    cmake_path (CONVERT "${CL_BINDIR}/../../../include" TO_NATIVE_PATH_LIST MSSTL_INCDIR NORMALIZE)
  else ()
    get_filename_component (CL_BINDIR "${CL_EXECUTABLE}" DIRECTORY)
    file (TO_NATIVE_PATH "${CL_BINDIR}/../../../include" MSSTL_INCDIR)
  endif ()
  list (APPEND COMPILER_INCLUDE_DIRS "${MSSTL_INCDIR}")

  # Detect Windows SDK and use its include dirs
  if (DEFINED ENV{CMAKE_WINDOWS_KITS_10_DIR})
    set (WINSDK_ROOT "$ENV{CMAKE_WINDOWS_KITS_10_DIR}")
  else ()
    get_filename_component (WINSDK_ROOT "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows Kits\\Installed Roots;KitsRoot10]" ABSOLUTE)
  endif ()
  set (WINSDK_INCDIR "${WINSDK_ROOT}/Include/${CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION}/")
  list (APPEND COMPILER_INCLUDE_DIRS "${WINSDK_INCDIR}/ucrt" "${WINSDK_INCDIR}/um" "${WINSDK_INCDIR}/shared")
else ()
  if (MSVC)
    message (WARNING "Clang-cl unsupported")
    file (TO_NATIVE_PATH "${PROJECT_BINARY_DIR}/empty" EMPTY_FILE_MSPATH)
    execute_process (COMMAND "${CMAKE_CXX_COMPILER}" "/E" "/Tp" "${EMPTY_FILE_MSPATH}" "/clang:-Wp,-v"
        RESULT_VARIABLE COMPILER_SEARCH_DIRS_COMMAND_RESULT
        ERROR_VARIABLE COMPILER_SEARCH_DIRS_RAW
        OUTPUT_QUIET
    )
  else ()
    execute_process (COMMAND "${CMAKE_CXX_COMPILER}" -E -x c++ "${PROJECT_BINARY_DIR}/empty" -Xpreprocessor -v
        RESULT_VARIABLE COMPILER_SEARCH_DIRS_COMMAND_RESULT
        ERROR_VARIABLE COMPILER_SEARCH_DIRS_RAW
        OUTPUT_QUIET
    )
  endif ()
  if (COMPILER_SEARCH_DIRS_COMMAND_RESULT)
    message (FATAL_ERROR "Unable to probe the compiler for its header search locations (${COMPILER_SEARCH_DIRS_COMMAND_RESULT})")
  endif ()

  string (REGEX MATCH "#include <...> search starts here:\n(.+)End of search list." IGNORE "${COMPILER_SEARCH_DIRS_RAW}")
  if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "AppleClang")
    string (REPLACE " \(framework directory\)" "" CMAKE_MATCH_1 "${CMAKE_MATCH_1}")
  endif ()
  string (REGEX REPLACE ";" "\\\\;" COMPILER_SEARCH_DIRS "${CMAKE_MATCH_1}")
  string (REGEX REPLACE "\n" ";" COMPILER_SEARCH_DIRS "${COMPILER_SEARCH_DIRS}")
  foreach (DIR ${COMPILER_SEARCH_DIRS})
    string (STRIP "${DIR}" DIR)
    list (APPEND COMPILER_INCLUDE_DIRS "${DIR}")
  endforeach ()
endif ()
