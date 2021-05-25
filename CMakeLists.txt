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

project (libSMCE VERSION 1.2.2)

if (NOT DEFINED SMCE_ARCH)
   set (SMCE_ARCH x86_64)
endif ()

include (FetchContent)
list (APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/CMake/Modules")

find_package (Threads REQUIRED)
include (SetupBoost)
include (Resources)

add_library (Ardrivo SHARED)
target_compile_features (Ardrivo PUBLIC cxx_std_20)
target_include_directories (Ardrivo PUBLIC include include/Ardrivo)
target_sources (Ardrivo PRIVATE
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

        include/Ardrivo/MQTT.h
        src/Ardrivo/MQTT.cpp

        src/SMCE/BoardData.cpp
        src/SMCE/BoardView.cpp
        src/SMCE/SharedBoardData.cpp
        src/Ardrivo/SMCE_main.cpp
)
target_link_libraries (Ardrivo PUBLIC Threads::Threads SMCE_Boost)
if (NOT WIN32)
   target_compile_options (Ardrivo PRIVATE "-Wall" "-Wextra" "-Wpedantic" "-Werror" "-Wcast-align")
   set_property (SOURCE src/Ardrivo/MQTT.cpp PROPERTY COMPILE_OPTIONS "-Wno-missing-field-initializers")
elseif (MSVC)
   target_compile_definitions (Ardrivo PRIVATE "_CRT_SECURE_NO_WARNINGS=1")
   target_compile_options (Ardrivo PRIVATE "/W4" "/permissive-" "/wd4244" "/wd4459" "/wd4716" "/WX")
endif ()
if (NOT CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
   set_target_properties (Ardrivo PROPERTIES LINK_FLAGS_RELEASE -s)
   if (DEFINED ENV{CXXRT_STATIC})
      set (CXXRT_STATIC $ENV{CXXRT_STATIC})
   else ()
      set (CXXRT_STATIC True)
  endif ()
   if (CXXRT_STATIC AND NOT APPLE AND CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
      target_link_options (Ardrivo PRIVATE -static-libstdc++ -static-libgcc)
   endif ()
endif ()

FetchContent_Declare (mosquitto
        GIT_REPOSITORY "https://github.com/eclipse/mosquitto"
        GIT_TAG v2.0.9)
FetchContent_GetProperties (mosquitto)
if (NOT mosquitto_POPULATED)
   set (CMAKE_POLICY_DEFAULT_CMP0048 NEW)
   FetchContent_Populate (mosquitto)
   if (DEFINED ENV{OPENSSL_USE_STATIC_LIBS})
      set (OPENSSL_USE_STATIC_LIBS $ENV{OPENSSL_USE_STATIC_LIBS} CACHE INTERNAL "")
   else ()
      set (OPENSSL_USE_STATIC_LIBS True CACHE INTERNAL "")
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
   if (WIN32)
      target_link_libraries (Ardrivo PRIVATE "crypt32.lib") # Due libmosquitto's bad use of OpenSSL
   endif ()
endif ()
target_link_libraries (Ardrivo PUBLIC libmosquitto_static)

add_library (SMCE)
target_compile_features (SMCE PUBLIC cxx_std_20)
target_include_directories (SMCE PUBLIC include)
target_sources (SMCE PRIVATE
      include/SMCE/internal/utils.hpp
      include/SMCE/SMCE_fs.hpp
      include/SMCE/internal/BoardData.hpp
      src/SMCE/BoardData.cpp
      include/SMCE/BoardView.hpp
      src/SMCE/BoardView.cpp
      include/SMCE/BoardConf.hpp
        include/SMCE/Board.hpp
        src/SMCE/Board.cpp
      include/SMCE/Toolchain.hpp
      src/SMCE/Toolchain.cpp
      include/SMCE/internal/SharedBoardData.hpp
      src/SMCE/SharedBoardData.cpp
      include/SMCE/Sketch.hpp
      src/SMCE/Sketch.cpp
      include/SMCE/Uuid.hpp
      src/SMCE/Uuid.cpp
      include/SMCE/SketchConf.hpp
)
target_link_libraries (SMCE PUBLIC Threads::Threads SMCE_Boost)
if (NOT WIN32)
   target_compile_options (SMCE PRIVATE "-Wall" "-Wextra" "-Wpedantic" "-Werror" "-Wcast-align")
elseif (MSVC)
   target_compile_options (SMCE PRIVATE "/W4" "/permissive-" "/wd4244" "/wd4459" "/WX")
endif ()
set_property (TARGET SMCE PROPERTY POSITION_INDEPENDENT_CODE True)

setup_smce_resources ()
add_dependencies (SMCE ArdRtRes)

add_subdirectory (test EXCLUDE_FROM_ALL)

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
set (CPACK_SYSTEM_NAME "${CMAKE_SYSTEM_NAME}-${SMCE_ARCH}-${SMCE_COMPILER_ID}")
if (MSVC)
   set (CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME}-${PROJECT_VERSION}-${CPACK_SYSTEM_NAME}-${CMAKE_BUILD_TYPE}")
endif ()
include (CPack)
