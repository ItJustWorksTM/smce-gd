#
#  PackagingProfiles/Default.cmake
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

if (WIN32)
  set (CPACK_GENERATOR ZIP 7Z)
else ()
  set (CPACK_GENERATOR TXZ TGZ STGZ)
endif ()

set (CPACK_PACKAGE_FILE_NAME "smce_gd-${PROJECT_VERSION}-${CPACK_SYSTEM_NAME}-${GODOT_BUILD_TYPE}")

if (MSVC)
  string (APPEND CPACK_PACKAGE_FILE_NAME "-${CMAKE_BUILD_TYPE}")
endif ()
