#
#  SetupBoost.cmake
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

add_library (SMCE_Boost INTERFACE)
find_package (Boost 1.74 COMPONENTS atomic filesystem)
if (Boost_FOUND)
    target_link_libraries (SMCE_Boost INTERFACE Boost::headers Boost::atomic Boost::filesystem)
else ()
#   set (Boost_DEBUG True)
    set (BOOST_ENABLE_CMAKE True)

    if(EXISTS "${PROJECT_SOURCE_DIR}/ext_deps/boost")
        set (Boost_SOURCE_DIR ext_deps/boost)
    else ()
        message ("Downloading Boost")
        FetchContent_Declare (Boost
            GIT_REPOSITORY "https://github.com/boostorg/boost"
            GIT_TAG "boost-1.75.0"
        )
        FetchContent_GetProperties (Boost)
        if(NOT Boost_POPULATED)
            FetchContent_Populate (Boost)
        endif()
    endif()
    add_subdirectory ("${Boost_SOURCE_DIR}" "${Boost_BINARY_DIR}" EXCLUDE_FROM_ALL)

    target_link_libraries (SMCE_Boost INTERFACE Boost::atomic Boost::filesystem)
    target_include_directories (SMCE_Boost INTERFACE ext_deps/boost/libs/dll/include)
endif ()

add_library (Boost_ipc INTERFACE)
if (WIN32)
    target_link_libraries (Boost_ipc INTERFACE ole32 oleaut32 psapi advapi32)
else ()
    target_link_libraries (Boost_ipc INTERFACE rt)
endif ()
add_library(Boost::ipc ALIAS Boost_ipc)

target_link_libraries (SMCE_Boost INTERFACE Boost_ipc)
