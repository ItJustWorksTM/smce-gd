#
#  ipcSMCE.cmake
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

include_guard ()

include (iSMCE)

add_library (ipcSMCE OBJECT)
set_property (TARGET ipcSMCE PROPERTY CXX_EXTENSIONS Off)
set_property (TARGET ipcSMCE PROPERTY POSITION_INDEPENDENT_CODE On)
target_link_libraries (ipcSMCE PUBLIC iSMCE)
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
