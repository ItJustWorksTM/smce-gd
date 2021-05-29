#
#  CMakeLists.txt
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

cmake_minimum_required (VERSION 3.16)

project (libSMCE VERSION 1.2.3)

set (SMCE_LIBRARY_TYPES "SHARED" "STATIC")
set (SMCE_EXTENDED_LIBRARY_TYPES "AUTO" ${SMCE_LIBRARY_TYPES} "SOURCE")

set (SMCE_LIBRARY_TYPE "SHARED" CACHE STRING "SHARED for a shared library, or STATIC for a static library")
if (NOT "${SMCE_LIBRARY_TYPE}" IN_LIST SMCE_LIBRARY_TYPES)
  message (FATAL_ERROR "SMCE_LIBRARY_TYPE must be SHARED or STATIC")
endif ()

set (SMCE_CXXRT_LINKING "SHARED" CACHE STRING "SHARED to dynamically link against the C++ runtime, or STATIC to link statically")
if (NOT "${SMCE_CXXRT_LINKING}" IN_LIST SMCE_LIBRARY_TYPES)
  message (FATAL_ERROR "SMCE_CXXRT_LINKING must be SHARED or STATIC")
endif ()

set (SMCE_BOOST_LINKING "${SMCE_LIBRARY_TYPE}" CACHE STRING "SHARED to dynamically link against Boost, or STATIC to link statically")
if (NOT "${SMCE_BOOST_LINKING}" IN_LIST SMCE_LIBRARY_TYPES)
  message (FATAL_ERROR "SMCE_BOOST_LINKING must be SHARED or STATIC")
endif ()

option (SMCE_ARDRIVO_MQTT "Set to \"Off\" to disable MQTT integration in Ardrivo" On)

if (SMCE_ARDRIVO_MQTT)
  if (NOT WIN32)
    set (SMCE_MOSQUITTO_LINKING "AUTO" CACHE STRING "AUTO to use the first available library found, or name one of SHARED, STATIC, or SOURCE to force")
    if (NOT "${SMCE_MOSQUITTO_LINKING}" IN_LIST SMCE_EXTENDED_LIBRARY_TYPES)
      message (FATAL_ERROR "SMCE_MOSQUITTO_LINKING must be AUTO, SHARED, STATIC, or SOURCE")
    endif ()
  else ()
    set (SMCE_MOSQUITTO_LINKING "SOURCE" CACHE INTERNAL "" FORCE)
  endif ()

  set (SMCE_OPENSSL_LINKING "${SMCE_LIBRARY_TYPE}" CACHE STRING "SHARED (the default) to dynamically link against OpenSSL, or STATIC to link statically; ignored when SMCE_MOSQUITTO_LINKING is not SOURCE")
  if (NOT "${SMCE_OPENSSL_LINKING}" IN_LIST SMCE_LIBRARY_TYPES)
    message (FATAL_ERROR "SMCE_OPENSSL_LINKING must be SHARED or STATIC")
  endif ()
else ()
    message ("User disabled SMCE_ARDRIVO_MQTT")
endif ()

set (PREV_CMAKE_MSVC_RUNTIME_LIBRARY "${CMAKE_MSVC_RUNTIME_LIBRARY}")

set (CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
if ("${SMCE_CXXRT_LINKING}" STREQUAL "SHARED")
  string (APPEND CMAKE_MSVC_RUNTIME_LIBRARY "DLL")
endif ()

include (FetchContent)
list (APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/CMake/Modules")

find_package (Threads REQUIRED)
include (SetupBoost)
if (SMCE_ARDRIVO_MQTT)
  include (SetupMosquitto)
endif ()
include (Resources)

add_library (ipcSMCE OBJECT)
set_property (TARGET ipcSMCE PROPERTY CXX_EXTENSIONS Off)
set_property (TARGET ipcSMCE PROPERTY POSITION_INDEPENDENT_CODE On)
target_compile_features (ipcSMCE PUBLIC cxx_std_20)
target_include_directories (ipcSMCE PUBLIC include)
target_link_libraries (ipcSMCE PUBLIC SMCE_Boost)
target_sources (ipcSMCE PRIVATE
    include/SMCE/internal/BoardData.hpp
    src/SMCE/BoardData.cpp
    include/SMCE/BoardView.hpp
    src/SMCE/BoardView.cpp
    include/SMCE/internal/SharedBoardData.hpp
    src/SMCE/SharedBoardData.cpp
)
if (NOT MSVC)
  target_compile_options (ipcSMCE PRIVATE "-Wall" "-Wextra" "-Wpedantic" "-Werror" "-Wcast-align")
else ()
  target_compile_options (ipcSMCE PRIVATE "/W4" "/permissive-" "/wd4244" "/wd4459" "/WX")
endif ()

add_library (Ardrivo SHARED)
set_property (TARGET Ardrivo PROPERTY CXX_EXTENSIONS Off)
target_compile_features (Ardrivo PUBLIC cxx_std_20)
target_include_directories (Ardrivo PUBLIC include/Ardrivo)
target_link_libraries (Ardrivo PUBLIC Threads::Threads ipcSMCE)
target_sources (Ardrivo PRIVATE
    src/Ardrivo/SMCE_main.cpp

    include/Ardrivo/Arduino.h
    src/Ardrivo/Arduino.cpp
    include/Ardrivo/HardwareSerial.h
    src/Ardrivo/HardwareSerial.cpp
    include/Ardrivo/OV767X.h
    src/Ardrivo/OV767X.cpp
    include/Ardrivo/Print.h
    src/Ardrivo/Print.cpp
    include/Ardrivo/SMCE.hpp
    include/Ardrivo/SMCE_dll.hpp
    include/Ardrivo/SMCE_numeric.hpp
    include/Ardrivo/Stream.h
    src/Ardrivo/Stream.cpp
    include/Ardrivo/WString.h
    src/Ardrivo/String.cpp
    include/Ardrivo/analogWrite.h
    include/Ardrivo/Client.h
    include/Ardrivo/IPAddress.h

    include/Ardrivo/SD.h
    src/Ardrivo/SD.cpp

    include/Ardrivo/WiFi.h
    src/Ardrivo/WiFi.cpp
)
if (SMCE_ARDRIVO_MQTT)
  target_sources (Ardrivo PRIVATE include/Ardrivo/MQTT.h src/Ardrivo/MQTT.cpp)
  target_link_libraries(Ardrivo PRIVATE SMCE_mosquitto)
endif ()

if (NOT MSVC)
  target_compile_options (Ardrivo PRIVATE "-Wall" "-Wextra" "-Wpedantic" "-Werror" "-Wcast-align")
  set_property (TARGET Ardrivo PROPERTY LINK_FLAGS_RELEASE -s)
  set_property (SOURCE src/Ardrivo/MQTT.cpp PROPERTY COMPILE_OPTIONS "-Wno-missing-field-initializers")
  if ("${SMCE_CXXRT_LINKING}" STREQUAL "STATIC" AND "${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    target_link_options (Ardrivo PRIVATE -static-libstdc++ -static-libgcc)
    #FIXME handle Clang/libc++
  endif ()
else ()
  target_compile_definitions (Ardrivo PRIVATE "_CRT_SECURE_NO_WARNINGS=1")
  target_compile_options (Ardrivo PRIVATE "/W4" "/permissive-" "/wd4244" "/wd4459" "/wd4716" "/WX")
endif ()

add_library (SMCE "${SMCE_LIBRARY_TYPE}")
set_property (TARGET SMCE PROPERTY CXX_EXTENSIONS Off)
set_property (TARGET SMCE PROPERTY POSITION_INDEPENDENT_CODE True)
target_compile_features (SMCE PUBLIC cxx_std_20)
target_include_directories (SMCE PUBLIC include)
target_link_libraries (SMCE PUBLIC Threads::Threads SMCE_Boost ipcSMCE)
target_sources (SMCE PRIVATE
    include/SMCE/internal/utils.hpp
    include/SMCE/SMCE_fs.hpp
    include/SMCE/BoardConf.hpp
    include/SMCE/Board.hpp
    src/SMCE/Board.cpp
    include/SMCE/Toolchain.hpp
    src/SMCE/Toolchain.cpp
    include/SMCE/Sketch.hpp
    src/SMCE/Sketch.cpp
    include/SMCE/Uuid.hpp
    src/SMCE/Uuid.cpp
    include/SMCE/SketchConf.hpp
)
if (NOT MSVC)
  target_compile_options (SMCE PRIVATE "-Wall" "-Wextra" "-Wpedantic" "-Werror" "-Wcast-align")
else ()
  target_compile_options (SMCE PRIVATE "/W4" "/permissive-" "/wd4244" "/wd4459" "/WX")
endif ()

setup_smce_resources ()
add_dependencies (SMCE ArdRtRes)

add_subdirectory (test EXCLUDE_FROM_ALL)

include (GNUInstallDirs)

file (REMOVE_RECURSE "${PROJECT_BINARY_DIR}/packaging")
file (MAKE_DIRECTORY "${PROJECT_BINARY_DIR}/packaging/include")
file (COPY "${PROJECT_SOURCE_DIR}/include/SMCE" DESTINATION "${PROJECT_BINARY_DIR}/packaging/include")
file (REMOVE_RECURSE "${PROJECT_BINARY_DIR}/packaging/include/SMCE/internal")
install (DIRECTORY "${PROJECT_BINARY_DIR}/packaging/include" DESTINATION ".")
install (FILES "$<TARGET_FILE:SMCE>" DESTINATION "lib64/SMCE")

install (FILES "LICENSE" "${SMCE_RESOURCES_ARK}" DESTINATION "share/SMCE")

if (CMAKE_CXX_SIMULATE_ID)
  set (SMCE_COMPILER_ID "${CMAKE_CXX_SIMULATE_ID}")
else ()
  set (SMCE_COMPILER_ID "${CMAKE_CXX_COMPILER_ID}")
endif ()
list (APPEND CPACK_GENERATOR STGZ TGZ ZIP)
set (CPACK_SYSTEM_NAME "${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}-${SMCE_COMPILER_ID}")
if (MSVC)
  set (CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME}-${PROJECT_VERSION}-${CPACK_SYSTEM_NAME}-${CMAKE_BUILD_TYPE}")
endif ()
include (CPack)

set (CMAKE_MSVC_RUNTIME_LIBRARY "${PREV_CMAKE_MSVC_RUNTIME_LIBRARY}")
