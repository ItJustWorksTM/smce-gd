#
#  SetupSMCE.cmake
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

include_guard ()

if (SMCEGD_SMCE_LINKING STREQUAL "AUTO")
  find_package (SMCE 1.4)
  if (SMCE_FOUND)
    if (TARGET SMCE::SMCE)
      set (SMCEGD_SMCE_LINKING "SHARED")
    elseif (TARGET SMCE::SMCE_static)
      set (SMCEGD_SMCE_LINKING "STATIC")
    endif ()
  else ()
    set (SMCEGD_SMCE_LINKING "SOURCE")
  endif ()
  message (STATUS "Resolved SMCEGD_SMCE_LINKING: AUTO -> ${SMCEGD_SMCE_LINKING}")
endif ()

if (SMCEGD_SMCE_LINKING STREQUAL "SHARED")
  find_package (SMCE 1.4 REQUIRED)
  if (NOT TARGET SMCE::SMCE)
    message (FATAL_ERROR "Shared link requested but libSMCE shared library not installed")
  endif ()
  add_library (smcegd_SMCE ALIAS SMCE::SMCE)
elseif (SMCEGD_SMCE_LINKING STREQUAL "STATIC")
  find_package (SMCE 1.4 REQUIRED)
  if (NOT TARGET SMCE::SMCE_static)
    message (FATAL_ERROR "Static link requested but libSMCE static library not installed")
  endif ()
  add_library (smcegd_SMCE ALIAS SMCE::SMCE_static)
elseif (SMCEGD_SMCE_LINKING STREQUAL "SOURCE")
  include (FetchContent)
  FetchContent_Declare (libsmce
      GIT_REPOSITORY "https://github.com/ItJustWorksTM/libSMCE"
      GIT_TAG v1.4.0
      GIT_SHALLOW On
  )
  FetchContent_GetProperties (libsmce)
  if (NOT libsmce_POPULATED)
    FetchContent_Populate (libsmce)

    file (READ "${libsmce_SOURCE_DIR}/CMakeLists.txt" libsmce_cmakelists)
    string (REPLACE "add_dependencies (SMCE ArdRtRes)" "add_dependencies (SMCE_static ArdRtRes)" libsmce_cmakelists "${libsmce_cmakelists}")
    file (WRITE "${libsmce_SOURCE_DIR}/CMakeLists.txt" "${libsmce_cmakelists}")
    file (APPEND "${libsmce_SOURCE_DIR}/CMakeLists.txt" "set (SMCE_RESOURCES_ARK \"\${SMCE_RESOURCES_ARK}\" CACHE INTERNAL \"\")\n")

    set (SMCE_BUILD_SHARED Off CACHE INTERNAL "")
    set (SMCE_BUILD_STATIC On CACHE INTERNAL "")
    set (SMCE_CXXRT_LINKING "${SMCEGD_CXXRT_LINKING}" CACHE INTERNAL "")
    set (SMCE_BOOST_LINKING "AUTO" CACHE INTERNAL "")
    add_subdirectory ("${libsmce_SOURCE_DIR}" "${libsmce_BINARY_DIR}" EXCLUDE_FROM_ALL)
  endif ()
  add_library (smcegd_SMCE ALIAS SMCE_static)
else ()
  message (FATAL_ERROR "SMCEGD_SMCE_LINKING: Unknown final link mode ${SMCEGD_SMCE_LINKING}")
endif ()
