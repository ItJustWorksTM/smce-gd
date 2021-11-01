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

cmake_minimum_required (VERSION 3.17)

project (godot-smce VERSION 1.3.2 LANGUAGES CXX)
list (APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/CMake/Modules")
include (UserConfigVars)

if (DEFINED SMCE_BUILD_PROFILE)
    include ("${PROJECT_SOURCE_DIR}/CMake/BuildProfiles/${SMCE_BUILD_PROFILE}.cmake")
endif ()

set (CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
if (SMCEGD_CXXRT_LINKING STREQUAL "SHARED")
    string (APPEND CMAKE_MSVC_RUNTIME_LIBRARY "DLL")
endif ()

set (CMAKE_CXX_STANDARD 20)
set (CMAKE_CXX_STANDARD_REQUIRED ON)
set (CMAKE_CXX_EXTENSIONS OFF)
set (CMAKE_POSITION_INDEPENDENT_CODE ON)

find_package (Threads REQUIRED)
find_package (SMCE 1.4 REQUIRED)

set (SMCE_TARGET SMCE::SMCE)
if (SMCEGD_SMCE_LINKING STREQUAL "STATIC")
    if (NOT TARGET SMCE::SMCE_static)
        message (FATAL_ERROR "Static link requested but libSMCE static library not installed")
    endif ()
    set (SMCE_TARGET SMCE::SMCE_static)
    message (STATUS "libSMCE statically linked")
endif ()

if (APPLE)
    set (CMAKE_BUILD_RPATH "@loader_path/../Frameworks;${CMAKE_BUILD_RPATH}")
    set (CMAKE_INSTALL_RPATH "@loader_path/../Frameworks;${CMAKE_INSTALL_RPATH}")
endif ()

include (CheckIPOSupported)
check_ipo_supported (RESULT CMAKE_IPO_SUPPORTED LANGUAGES CXX)
set (CMAKE_INTERPROCEDURAL_OPTIMIZATION ${CMAKE_IPO_SUPPORTED})

include (FetchContent)
list (APPEND GDCPP_NEEDED_CLASSES Reference Node Resource _ResourceLoader)
include (SetupGodotCpp)

add_library (godot-smce MODULE)
target_sources (godot-smce PRIVATE
        src/lib.cxx
        src/bind/Board.cxx
        src/bind/Toolchain.cxx
        src/bind/Sketch.cxx
        src/bind/BoardView.cxx
        src/bind/UartSlurper.cxx
        src/bind/BoardConfig.cxx
        src/gd/BraceEnabler.cxx
        src/bind/FrameBuffer.cxx)

target_include_directories (godot-smce PUBLIC include)
target_link_libraries (godot-smce PUBLIC godot-cpp ${SMCE_TARGET})

if (NOT CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    set_target_properties (godot-smce PROPERTIES LINK_FLAGS_RELEASE -s)
    if (SMCEGD_CXXRT_LINKING STREQUAL "STATIC" AND CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        target_link_options (godot-smce PRIVATE -static-libstdc++ -static-libgcc)
    endif ()
endif ()

get_target_property (SMCE_RT_RES SMCE::SMCE RESOURCES_ARCHIVE)

file (MAKE_DIRECTORY "${PROJECT_SOURCE_DIR}/project/gdnative/lib/RtResources")
add_custom_command (TARGET godot-smce POST_BUILD
        COMMAND "${CMAKE_COMMAND}" -E copy "$<TARGET_FILE:godot-smce>" "${PROJECT_SOURCE_DIR}/project/gdnative/lib/"
        COMMAND "${CMAKE_COMMAND}" -E tar xf "${SMCE_RT_RES}"
        COMMAND "${CMAKE_COMMAND}" -E copy_directory "./RtResources" "${PROJECT_SOURCE_DIR}/project/share/RtResources"
        COMMAND "${CMAKE_COMMAND}" -E rm -rf "./RtResources"
        WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
)

include(GNUInstallDirs)

if (NOT GODOT_DEBUG)
    set (GODOT_BUILD_TYPE "GodotRelease")
    set (GODOT_DEBUG_ARG "")
else ()
    set (GODOT_BUILD_TYPE "GodotDebug")
    set (GODOT_DEBUG_ARG "-debug")
endif ()

include (CPackCommon)



if (WIN32)
    set (GODOT_PLATFORM windows)
elseif (APPLE)
    set (GODOT_PLATFORM macos)
else ()
    set (GODOT_PLATFORM linux)
endif ()
file (REMOVE_RECURSE "${PROJECT_BINARY_DIR}/export")
file (MAKE_DIRECTORY "${PROJECT_BINARY_DIR}/export")

if (SMCEGD_BUNDLE_DEPS)
    if (UNIX AND NOT APPLE)
        set (SMCE_DYLIB_VER_SUFFIX ".1")
    elseif (APPLE)
        set (SMCE_DYLIB_VER_PRESUFFIX ".1")
    endif ()

    set (SMCE_DYNLIB_FILE "$<TARGET_FILE_DIR:godot-smce>/${CMAKE_SHARED_LIBRARY_PREFIX}SMCE${SMCE_DYLIB_VER_PRESUFFIX}${CMAKE_SHARED_LIBRARY_SUFFIX}${SMCE_DYLIB_VER_SUFFIX}")
    add_custom_command (TARGET godot-smce POST_BUILD
        COMMAND "${CMAKE_COMMAND}" -E copy_if_different "$<TARGET_FILE:SMCE::SMCE>" "${SMCE_DYNLIB_FILE}"
    )
endif ()

install (CODE "find_program (GODOT_EXECUTABLE NAMES godot3-headless godot-headless godot3-server godot-server godot3 godot REQUIRED)")
if (NOT APPLE)
    install (CODE "
        execute_process (COMMAND \"\${GODOT_EXECUTABLE}\" --no-window --export${GODOT_DEBUG_ARG} \"${GODOT_PLATFORM}\" \"${PROJECT_BINARY_DIR}/export/smce_gd${CMAKE_EXECUTABLE_SUFFIX}\" WORKING_DIRECTORY \"${CMAKE_SOURCE_DIR}/project\")
        if (NOT EXISTS \"${PROJECT_BINARY_DIR}/export/smce_gd${CMAKE_EXECUTABLE_SUFFIX}\")
            message (FATAL_ERROR \"Godot export failure\")
        endif ()
    ")
    install (PROGRAMS "${PROJECT_BINARY_DIR}/export/smce_gd${CMAKE_EXECUTABLE_SUFFIX}" DESTINATION "${CMAKE_INSTALL_LIBDIR}/smce")
    set_property (INSTALL "${CMAKE_INSTALL_LIBDIR}/smce/smce_gd${CMAKE_EXECUTABLE_SUFFIX}" PROPERTY CPACK_START_MENU_SHORTCUTS "SMCE Godot")
    install (FILES "${PROJECT_BINARY_DIR}/export/$<TARGET_FILE_NAME:godot-smce>" DESTINATION "${CMAKE_INSTALL_LIBDIR}/smce")

    if (NOT WIN32)
        install (FILES "${PROJECT_SOURCE_DIR}/smce_gd.desktop" DESTINATION "share/applications")
    endif ()

    if (SMCEGD_BUNDLE_DEPS)
        install (FILES "${SMCE_DYNLIB_FILE}" DESTINATION "${CMAKE_INSTALL_LIBDIR}/smce")
    endif ()

else ()
    install (CODE "
        execute_process (COMMAND \"\${GODOT_EXECUTABLE}\" --no-window --export${GODOT_DEBUG_ARG} \"${GODOT_PLATFORM}\" \"${PROJECT_BINARY_DIR}/export/SMCE-Godot\"
                         WORKING_DIRECTORY \"${CMAKE_SOURCE_DIR}/project\")
        if (NOT EXISTS \"${PROJECT_BINARY_DIR}/export/SMCE-Godot\")
            message (FATAL_ERROR \"Godot export failure\")
        endif ()
        execute_process (COMMAND \"${CMAKE_COMMAND}\" -E tar xf \"${PROJECT_BINARY_DIR}/export/SMCE-Godot\"
                         WORKING_DIRECTORY \"${PROJECT_BINARY_DIR}/export\")
        execute_process (COMMAND defaults write \"${PROJECT_BINARY_DIR}/export/SMCE-Godot.app/Contents/Info.plist\" LSEnvironment -dict PATH \"/bin:/usr/bin:/usr/local/bin:/opt/homebrew/bin:\")
    ")
    if (SMCEGD_BUNDLE_DEPS)
        install (FILES "${SMCE_DYNLIB_FILE}" DESTINATION "${PROJECT_BINARY_DIR}/export/SMCE-Godot.app/Contents/Frameworks")
    endif()
    if (FORCE_STRIP_CODESIGNING)
        find_program (CODESIGN_EXECUTABLE codesign REQUIRED)
        install (CODE "
            execute_process (COMMAND \"${CODESIGN_EXECUTABLE}\" --remove-signature \"${PROJECT_BINARY_DIR}/export/SMCE-Godot.app\")
        ")
    endif ()
    install (CODE "
        file (INSTALL \"${PROJECT_BINARY_DIR}/export/SMCE-Godot.app\" DESTINATION \"\${CMAKE_INSTALL_PREFIX}\" USE_SOURCE_PERMISSIONS)
    ")
endif ()

file (WRITE "${PROJECT_SOURCE_DIR}/project/share/version.txt" "${PROJECT_VERSION}${GODOT_DEBUG_ARG}")

if (NOT DEFINED SMCE_CPACK_PROFILE)
    set (SMCE_CPACK_PROFILE "Archive")
endif ()
include ("${PROJECT_SOURCE_DIR}/CMake/PackagingProfiles/${SMCE_CPACK_PROFILE}.cmake")

include (CPack)
