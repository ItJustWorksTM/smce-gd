#
#  Coverage.cmake
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

option (SMCE_COVERAGE "Enable coverage reporting" Off)
message (STATUS "SMCE_COVERAGE: ${SMCE_COVERAGE}")

function (configure_coverage TARGET_NAME)
  if (NOT SMCE_COVERAGE)
    return ()
  endif ()

  if ("${CMAKE_CXX_COMPILER_ID}" MATCHES "GNU|Clang")
    target_compile_options ("${TARGET_NAME}" PRIVATE -O0 -g --coverage)
    target_link_options ("${TARGET_NAME}" PRIVATE --coverage)
  else ()
    message (WARNING "User enabled coverage but compiler does not support instrumentation for coverage")
  endif ()
endfunction ()
