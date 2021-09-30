#
#  UseHighestCxxStandard.cmake
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

foreach (CXX_COMPILE_FEATURE ${CMAKE_CXX_COMPILE_FEATURES})
  if (CXX_COMPILE_FEATURE MATCHES "cxx_std_([0-8][0-9]+)")
    list (APPEND CXX_SUPPORTED_VERSIONS "${CMAKE_MATCH_1}")
  endif ()
endforeach ()
list (SORT CXX_SUPPORTED_VERSIONS)
list (REVERSE CXX_SUPPORTED_VERSIONS)
list (GET CXX_SUPPORTED_VERSIONS 1 CXX_HIGHEST_SUPPORTED_VERSION)
set (CMAKE_CXX_STANDARD "${CXX_HIGHEST_SUPPORTED_VERSION}")
message (STATUS "Using CMAKE_CXX_STANDARD: ${CMAKE_CXX_STANDARD}")
