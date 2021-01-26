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

project (libSMCE)

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
        include/Ardrivo/Print.h
        include/Ardrivo/SMCE.hpp
        include/Ardrivo/SMCE_dll.hpp
        include/Ardrivo/Stream.h
        src/Ardrivo/Stream.cpp
        include/Ardrivo/WString.h
        src/Ardrivo/String.cpp
        include/Ardrivo/analogWrite.h

        include/Ardrivo/MQTT.h
        src/Ardrivo/MQTT.cpp

        src/SMCE/BoardData.cpp
        src/SMCE/BoardView.cpp
        src/SMCE/SharedBoardData.cpp
        src/Ardrivo/SMCE_main.cpp
)
target_link_libraries (Ardrivo PUBLIC Threads::Threads SMCE_Boost)
set (PAHO_BUILD_STATIC True)
set (PAHO_BUILD_SHARED False)
set (PAHO_WITH_SSL True)
set (PAHO_ENABLE_TESTING False)
FetchContent_Declare (Paho
        GIT_REPOSITORY "https://github.com/eclipse/paho.mqtt.c"
        GIT_TAG master)
FetchContent_GetProperties (Paho)
if(NOT paho_POPULATED)
   FetchContent_Populate (Paho)
endif ()
add_subdirectory ("${paho_SOURCE_DIR}" "${paho_BINARY_DIR}" EXCLUDE_FROM_ALL)
set_property(TARGET paho-mqtt3c-static PROPERTY POSITION_INDEPENDENT_CODE ON)
target_link_libraries (Ardrivo PUBLIC paho-mqtt3c-static)

add_library (SMCE)
target_compile_features (SMCE PUBLIC cxx_std_20)
target_include_directories (SMCE PUBLIC include)
target_sources (SMCE PRIVATE
      include/SMCE/SMCE_fs.hpp
      include/SMCE/internal/BoardData.hpp
      src/SMCE/BoardData.cpp
      include/SMCE/BoardView.hpp
      src/SMCE/BoardView.cpp
      include/SMCE/BoardConf.hpp
      include/SMCE/BoardRunner.hpp
      src/SMCE/BoardRunner.cpp
      include/SMCE/ExecutionContext.hpp
      src/SMCE/ExecutionContext.cpp
      include/SMCE/internal/SharedBoardData.hpp
      src/SMCE/SharedBoardData.cpp
      include/SMCE/SketchConf.hpp
)
target_link_libraries (SMCE PUBLIC Threads::Threads SMCE_Boost)
if (NOT WIN32)
   target_compile_options (SMCE PUBLIC "-Wall" "-Wextra")
endif ()

setup_smce_resources ()
add_dependencies (SMCE ArdRtRes)

