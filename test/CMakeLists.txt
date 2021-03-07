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

find_package(Catch2 QUIET)
if (NOT Catch2_FOUND)
    FetchContent_Declare (
        Catch2
        GIT_REPOSITORY https://github.com/catchorg/Catch2.git
        GIT_TAG        v2.13.4
    )
    FetchContent_GetProperties (Catch2)
    if (NOT catch2_POPULATED)
        FetchContent_Populate (Catch2)
    endif ()
    add_subdirectory ("${catch2_SOURCE_DIR}" "${catch2_BINARY_DIR}" EXCLUDE_FROM_ALL)
    list (APPEND CMAKE_MODULE_PATH "${Catch2_SOURCE_DIR}/contrib")
endif ()

include (CTest)
include (Catch)

add_executable (SMCE_Tests main.cpp)
target_link_libraries (SMCE_Tests PUBLIC SMCE Catch2::Catch2WithMain)
catch_discover_tests (SMCE_Tests)

set (SMCE_TEST_DIR "${CMAKE_CURRENT_BINARY_DIR}/test_dir")
file (MAKE_DIRECTORY "${SMCE_TEST_DIR}/smce_root")
add_custom_command (TARGET SMCE_Tests POST_BUILD
    WORKING_DIRECTORY "${SMCE_TEST_DIR}/smce_root"
    COMMAND "${CMAKE_COMMAND}" -E tar xf "${SMCE_RESOURCES_ARK}"
)
file (COPY sketches DESTINATION "${SMCE_TEST_DIR}")
file (COPY patches DESTINATION "${SMCE_TEST_DIR}")
target_compile_definitions (SMCE_Tests PUBLIC "SMCE_TEST_DIR=\"${SMCE_TEST_DIR}\"")

