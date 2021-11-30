#
#  UserConfigVars.cmake
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

set (SMCEGD_LIBRARY_TYPES "SHARED" "STATIC")
set (SMCEGD_EXTENDED_LIBRARY_TYPES "AUTO" ${SMCEGD_LIBRARY_TYPES} "SOURCE")

set (SMCEGD_CXXRT_LINKING "SHARED" CACHE STRING "SHARED to dynamically link against the C++ runtime, or STATIC to link statically")
if (NOT "${SMCEGD_CXXRT_LINKING}" IN_LIST SMCEGD_LIBRARY_TYPES)
  message (FATAL_ERROR "SMCEGD_CXXRT_LINKING must be SHARED or STATIC")
endif ()

set (SMCEGD_SMCE_LINKING "SHARED" CACHE STRING "SHARED to dynamically link against libSMCE, STATIC to link statically, AUTO to pick the simplest available option, or SOURCE to build from source")
if (NOT "${SMCEGD_SMCE_LINKING}" IN_LIST SMCEGD_EXTENDED_LIBRARY_TYPES)
  message (FATAL_ERROR "SMCEGD_SMCE_LINKING must be SHARED or STATIC")
endif ()

option (SMCEGD_BUNDLE_DEPS False "Set to True to bundle during packaging shared libs required at runtime")
if (SMCEGD_BUNDLE_DEPS AND NOT SMCEGD_SMCE_LINKING STREQUAL "SHARED")
  message (FATAL_ERROR "SMCEGD_BUNDLE_DEPS may only be set to True when SMCEGD_SMCE_LINKING is explicitly \"SHARED\"")
endif ()
