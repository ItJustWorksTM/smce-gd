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

# Invars:
# - SMCE_ROOT [opt] : The location of a libSMCE install tree
# - SMCE_AUTODOWNLOAD [opt] : Set to True to download SMCE automatically if SMCE_ROOT is not set

# Outtargets:
# - SMCE : the imported static library and its associated headers
# Outvars:
# - SMCE_ROOT : The location of the used libSMCE install tree

set (SMCE_EXPECTED_TAG 1.1.0)
set (SMCE_EXPECTED_VERSION 1.1.0)
set (SMCE_EXPECTED_ARCH x86_64)

if (NOT SMCE_ROOT AND SMCE_AUTODOWNLOAD)
    set (SMCE_BASENAME "libSMCE-${SMCE_EXPECTED_VERSION}-${CMAKE_SYSTEM_NAME}-${SMCE_EXPECTED_ARCH}-${CMAKE_CXX_COMPILER_ID}")
    set (SMCE_ARK_FILENAME "${SMCE_BASENAME}.zip")
    set (SMCE_ROOT "${CMAKE_CURRENT_BINARY_DIR}/smce-autodl")
    file (MAKE_DIRECTORY "${SMCE_ROOT}")
    if (NOT EXISTS "${CMAKE_CURRENT_BINARY_DIR}/${SMCE_BASENAME}")
        file (DOWNLOAD "https://github.com/ItJustWorksTM/libSMCE/releases/download/v${SMCE_EXPECTED_TAG}/sha512.txt"
                "${SMCE_ROOT}/sha512.txt"
                TLS_VERIFY ON)
        file (STRINGS "${SMCE_ROOT}/sha512.txt" SMCE_${SMCE_EXPECTED_VERSION}_SHA512s
                LENGTH_MINIMUM 130) # 128 xnums + 2 padding spaces
        foreach (SMCE_SHA512_LINE ${SMCE_${SMCE_EXPECTED_VERSION}_SHA512s})
            string (SUBSTRING "${SMCE_SHA512_LINE}" 130 -1 SMCE_SHA512_FNAME)
            if (SMCE_SHA512_FNAME STREQUAL SMCE_ARK_FILENAME)
                string (SUBSTRING "${SMCE_SHA512_LINE}" 0 128 SMCE_ARK_HASH)
                break ()
            endif ()
        endforeach ()
        file (DOWNLOAD "https://github.com/ItJustWorksTM/libSMCE/releases/download/v${SMCE_EXPECTED_TAG}/${SMCE_ARK_FILENAME}"
                "${SMCE_ROOT}/${SMCE_ARK_FILENAME}"
                SHOW_PROGRESS
                TLS_VERIFY ON
                EXPECTED_HASH SHA512=${SMCE_ARK_HASH})
        execute_process (COMMAND "${CMAKE_COMMAND}" -E tar xf "${SMCE_ROOT}/${SMCE_ARK_FILENAME}"
                WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")
        file (REMOVE_RECURSE "${SMCE_ROOT}")
    endif ()
    set (SMCE_ROOT "${CMAKE_CURRENT_BINARY_DIR}/${SMCE_BASENAME}")
endif ()

if (NOT SMCE_ROOT)
    message (FATAL_ERROR "No path to SMCE has been provided (in SMCE_ROOT)")
elseif(NOT EXISTS "${SMCE_ROOT}")
    message (FATAL_ERROR "A path to SMCE has been provided (\"${SMCE_ROOT}\"), but it could not be found on the filesystem")
endif ()

add_library (SMCE IMPORTED STATIC)
target_include_directories (SMCE INTERFACE "${SMCE_ROOT}/include")
set_property (TARGET SMCE PROPERTY IMPORTED_LOCATION "${SMCE_ROOT}/lib64/SMCE/${CMAKE_STATIC_LIBRARY_PREFIX}SMCE${CMAKE_STATIC_LIBRARY_SUFFIX}")

if (WIN32)
    target_link_libraries (SMCE INTERFACE ole32 oleaut32 psapi advapi32)
elseif (NOT APPLE)
    target_link_libraries (SMCE INTERFACE rt)
endif ()

file (GLOB WA_BOOST_LIBS LIST_DIRECTORIES false "${SMCE_ROOT}/lib64/boost/*")
message ("Found the following Boost workaround libs: ${WA_BOOST_LIBS}")
if (WA_BOOST_LIBS)
    add_library (WA_Boost INTERFACE)
    foreach (WA_BLIB ${WA_BOOST_LIBS})
        if (IS_SYMLINK "${WA_BOOST_LIBS}")
                message (FATAL_ERROR "Workaround Boost lib \"${WA_BLIB}\" is a symlink")
        elseif (IS_DIRECTORY "${WA_BOOST_LIBS}")
                message (FATAL_ERROR "Workaround Boost lib \"${WA_BLIB}\" is a directory")
        endif ()
        target_link_libraries (WA_Boost INTERFACE "${WA_BLIB}")
    endforeach ()
    target_link_libraries (SMCE INTERFACE WA_Boost)
endif ()
