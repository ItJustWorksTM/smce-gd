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
cmake_policy (SET CMP0022 NEW)

project (libSMCE VERSION 1.2.4)
list (APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/CMake/Modules")
include (UserConfigVars)

if (DEFINED SMCE_BUILD_PROFILE)
  include ("${PROJECT_SOURCE_DIR}/CMake/BuildProfiles/${SMCE_BUILD_PROFILE}.cmake")
endif ()

include (Coverage)

set (PREV_CMAKE_MSVC_RUNTIME_LIBRARY "${CMAKE_MSVC_RUNTIME_LIBRARY}")
set (CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
if ("${SMCE_CXXRT_LINKING}" STREQUAL "SHARED")
  string (APPEND CMAKE_MSVC_RUNTIME_LIBRARY "DLL")
endif ()

# Prime the local target exports file
export (TARGETS FILE "${PROJECT_BINARY_DIR}/cmake/SMCETargets.cmake")

find_package (Threads REQUIRED)
include (SetupBoost)
if (SMCE_ARDRIVO_MQTT)
  include (SetupMosquitto)
endif ()
include (Resources)

include (ipcSMCE)

add_library (Ardrivo SHARED)
configure_coverage (Ardrivo)
set_property (TARGET Ardrivo PROPERTY CXX_EXTENSIONS Off)
target_include_directories (Ardrivo PRIVATE include/Ardrivo)
target_link_libraries (Ardrivo PRIVATE ipcSMCE)
target_sources (Ardrivo PRIVATE
    src/Ardrivo/SMCE_main.cpp

    include/Ardrivo/Arduino.h
    src/Ardrivo/Arduino.cpp
    include/Ardrivo/HardwareSerial.h
    src/Ardrivo/HardwareSerial.cpp
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
if (SMCE_ARDRIVO_OV767X)
  target_sources (Ardrivo PRIVATE include/Ardrivo/OV767X.h src/Ardrivo/OV767X.cpp)
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

add_library (objSMCE OBJECT)
configure_coverage (objSMCE)
set_property (TARGET objSMCE PROPERTY CXX_EXTENSIONS Off)
set_property (TARGET objSMCE PROPERTY POSITION_INDEPENDENT_CODE True)
target_link_libraries (objSMCE PUBLIC ipcSMCE)
target_sources (objSMCE PRIVATE
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
  target_compile_options (objSMCE PRIVATE "-Wall" "-Wextra" "-Wpedantic" "-Werror" "-Wcast-align")
else ()
  target_compile_options (objSMCE PRIVATE "/W4" "/permissive-" "/wd4244" "/wd4459" "/WX")
endif ()

if (SMCE_BUILD_SHARED)
  add_library (SMCE SHARED)
  configure_coverage (SMCE)
  target_link_libraries (SMCE
      PRIVATE objSMCE ipcSMCE
      PUBLIC iSMCE
  )
  set_property (TARGET SMCE PROPERTY VERSION "${PROJECT_VERSION}")
  set_property (TARGET SMCE PROPERTY SOVERSION "${PROJECT_VERSION_MAJOR}")
  set_property (TARGET SMCE PROPERTY INTERFACE_SMCE_MAJOR_VERSION "${PROJECT_VERSION_MAJOR}")
  set_property (TARGET SMCE APPEND PROPERTY COMPATIBLE_INTERFACE_STRING SMCE_MAJOR_VERSION)
endif ()

if (SMCE_BUILD_STATIC)
  add_library (SMCE_static STATIC)
  configure_coverage (SMCE_static)
  target_link_libraries (SMCE_static
      PRIVATE objSMCE ipcSMCE
      PUBLIC iSMCE
  )
  set_property (TARGET SMCE_static PROPERTY INTERFACE_SMCE_MAJOR_VERSION "${PROJECT_VERSION_MAJOR}")
  set_property (TARGET SMCE_static APPEND PROPERTY COMPATIBLE_INTERFACE_STRING SMCE_MAJOR_VERSION)
endif ()


setup_smce_resources ()
add_dependencies (SMCE ArdRtRes)

add_subdirectory (test EXCLUDE_FROM_ALL)


include (InstallFragments)

smce_install_boilerplate_targets (${SMCE_COMPONENT_BOILERPLATE})

set (SMCE_EXPORTED_TARGETS)
if (SMCE_BUILD_SHARED)
  list (APPEND SMCE_EXPORTED_TARGETS SMCE)
  smce_install (TARGETS SMCE ${SMCE_COMPONENT_SHARED})
endif()
if (SMCE_BUILD_STATIC)
  list (APPEND SMCE_EXPORTED_TARGETS SMCE_static)
  smce_install (TARGETS SMCE_static ${SMCE_COMPONENT_STATIC})
endif ()

smce_export (TARGETS ${SMCE_EXPORTED_TARGETS})

include (GNUInstallDirs)
install (EXPORT SMCETargets
    ${SMCE_COMPONENT_TARGETS}
    FILE SMCETargets.cmake
    NAMESPACE SMCE::
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/SMCE"
)

smce_install_config ()

file (REMOVE_RECURSE "${PROJECT_BINARY_DIR}/packaging")
file (MAKE_DIRECTORY "${PROJECT_BINARY_DIR}/packaging/include")
file (COPY "${PROJECT_SOURCE_DIR}/include/SMCE" DESTINATION "${PROJECT_BINARY_DIR}/packaging/include")
file (REMOVE_RECURSE "${PROJECT_BINARY_DIR}/packaging/include/SMCE/internal")
install (DIRECTORY "${PROJECT_BINARY_DIR}/packaging/include" DESTINATION "." ${SMCE_COMPONENT_HEADERS})

install (FILES
    "${PROJECT_SOURCE_DIR}/LICENSE"
    "${SMCE_RESOURCES_ARK}"
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/SMCE"
    ${SMCE_COMPONENT_RTDATA}
)

include (CPackCommon)

if (NOT DEFINED SMCE_CPACK_PROFILE)
  set (SMCE_CPACK_PROFILE "Archive")
endif ()

include ("${PROJECT_SOURCE_DIR}/CMake/PackagingProfiles/${SMCE_CPACK_PROFILE}.cmake")

get_cmake_property (CPACK_COMPONENTS_ALL COMPONENTS)
list (REMOVE_ITEM CPACK_COMPONENTS_ALL "Unspecified")
include (CPack)

set (CMAKE_MSVC_RUNTIME_LIBRARY "${PREV_CMAKE_MSVC_RUNTIME_LIBRARY}")
