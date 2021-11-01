#
#  CPackCommon.cmake
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

if (CMAKE_CXX_SIMULATE_ID)
  set (SMCE_COMPILER_ID "${CMAKE_CXX_SIMULATE_ID}")
else ()
  set (SMCE_COMPILER_ID "${CMAKE_CXX_COMPILER_ID}")
endif ()

set (CPACK_SYSTEM_NAME "${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}-${SMCE_COMPILER_ID}")

set (CPACK_PACKAGE_NAME "SMCE Godot")
set (CPACK_PACKAGE_INSTALL_DIRECTORY "${CPACK_PACKAGE_NAME}")
set (CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set (CPACK_PACKAGE_VENDOR "ItJustWorksTM")
set (CPACK_PACKAGE_CONTACT "${CPACK_PACKAGE_VENDOR} <itjustworkstm@aerostun.dev>")
set (CMAKE_PROJECT_DESCRIPTION "A frontend for libSMCE made with Godot using GDNative")
set (CMAKE_PROJECT_HOMEPAGE_URL "https://github.com/ItJustWorksTM/smce-gd")
set (CPACK_PACKAGE_DESCRIPTION "An emulated environment for Arduino-based vehicles; primarily designed for use with the smartcar_shield library.")

configure_file ("${PROJECT_SOURCE_DIR}/LICENSE" "${PROJECT_BINARY_DIR}/LICENSE.txt" COPYONLY)
set (CPACK_RESOURCE_FILE_LICENSE "${PROJECT_BINARY_DIR}/LICENSE.txt")
