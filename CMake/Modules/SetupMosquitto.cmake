#
#  SetupMosquitto.cmake
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
add_library (SMCE_mosquitto INTERFACE)

message (STATUS "SMCE_MOSQUITTO_LINKING: ${SMCE_MOSQUITTO_LINKING}")
if ("${SMCE_MOSQUITTO_LINKING}" STREQUAL "AUTO")
  find_package (PkgConfig)
  if (PKG_CONFIG_FOUND)
    pkg_check_modules (Mosquitto libmosquitto)
    if (Mosquitto_FOUND)
      set (SMCE_MOSQUITTO_LINKING "SHARED")
    elseif (Mosquitto_STATIC_FOUND)
      set (SMCE_MOSQUITTO_LINKING "STATIC")
    else ()
      set (SMCE_MOSQUITTO_LINKING "SOURCE")
    endif ()
  else ()
    message (WARNING "pkg-config was not found, so we were not able to determine whether or not you have libmosquitto installed; using SOURCE linking")
    set (SMCE_MOSQUITTO_LINKING "SOURCE")
  endif ()
  message (STATUS "Resolved SMCE_MOSQUITTO_LINKING: AUTO -> ${SMCE_MOSQUITTO_LINKING}")
endif ()


if ("${SMCE_MOSQUITTO_LINKING}" STREQUAL "SHARED")
  pkg_check_modules (Mosquitto REQUIRED libmosquitto)
  if (NOT Mosquitto_FOUND)
    message (FATAL_ERROR "Could not find libmosquitto shared library")
  endif ()
  target_include_directories (SMCE_mosquitto INTERFACE ${Mosquitto_INCLUDE_DIRS})
  target_link_libraries (SMCE_mosquitto INTERFACE ${Mosquitto_LINK_LIBRARIES})
  target_compile_options (SMCE_mosquitto INTERFACE ${Mosquitto_CFLAGS})
  target_link_options (SMCE_mosquitto INTERFACE ${Mosquitto_LDFLAGS})
elseif ("${SMCE_MOSQUITTO_LINKING}" STREQUAL "STATIC")
  pkg_check_modules (Mosquitto REQUIRED libmosquitto)
  if (NOT Mosquitto_STATIC_FOUND)
    message (FATAL_ERROR "Could not find libmosquitto static library")
  endif ()
  target_include_directories (SMCE_mosquitto INTERFACE ${Mosquitto_STATIC_INCLUDE_DIRS})
  target_link_libraries (SMCE_mosquitto INTERFACE ${Mosquitto_STATIC_LINK_LIBRARIES})
  target_compile_options (SMCE_mosquitto INTERFACE ${Mosquitto_STATIC_CFLAGS})
  target_link_options (SMCE_mosquitto INTERFACE ${Mosquitto_STATIC_LDFLAGS})
elseif ("${SMCE_MOSQUITTO_LINKING}" STREQUAL "SOURCE")
  FetchContent_Declare (mosquitto
      GIT_REPOSITORY "https://github.com/eclipse/mosquitto"
      GIT_TAG v2.0.10
  )
  FetchContent_GetProperties (mosquitto)
  if (NOT mosquitto_POPULATED)
    set (CMAKE_POLICY_DEFAULT_CMP0048 NEW)
    FetchContent_Populate (mosquitto)
    if ("${SMCE_OPENSSL_LINKING}" STREQUAL "STATIC")
      set (OPENSSL_USE_STATIC_LIBS True CACHE INTERNAL "")
    else ()
      set (OPENSSL_USE_STATIC_LIBS False CACHE INTERNAL "")
    endif ()
    set (WITH_STATIC_LIBRARIES True CACHE INTERNAL "")
    set (WITH_THREADING False CACHE INTERNAL "")
    set (WITH_PIC True CACHE INTERNAL "")
    set (WITH_CLIENTS False CACHE INTERNAL "")
    set (WITH_BROKER False CACHE INTERNAL "")
    set (WITH_APPS False CACHE INTERNAL "")
    set (WITH_PLUGINS False CACHE INTERNAL "")
    set (DOCUMENTATION False CACHE INTERNAL "")
    set (WITH_CJSON False CACHE INTERNAL "")
    set (WITH_LIB_CPP False CACHE INTERNAL "")

    list (APPEND CMAKE_MODULE_PATH "${mosquitto_SOURCE_DIR}/cmake/")
    add_subdirectory ("${mosquitto_SOURCE_DIR}" "${mosquitto_BINARY_DIR}" EXCLUDE_FROM_ALL)
    target_include_directories (libmosquitto_static INTERFACE "${mosquitto_SOURCE_DIR}/include")
    if (WIN32) # or should that be MSVC?
      target_link_libraries (SMCE_mosquitto INTERFACE "crypt32.lib") # Due libmosquitto's bad use of OpenSSL
    endif ()
  endif ()
  target_link_libraries (SMCE_mosquitto INTERFACE libmosquitto_static)
endif ()
