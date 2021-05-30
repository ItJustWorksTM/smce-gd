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

set (SMCE_LIBRARY_TYPES "SHARED" "STATIC")
set (SMCE_EXTENDED_LIBRARY_TYPES "AUTO" ${SMCE_LIBRARY_TYPES} "SOURCE")

set (SMCE_LIBRARY_TYPE "SHARED" CACHE STRING "SHARED for a shared library, or STATIC for a static library")
if (NOT "${SMCE_LIBRARY_TYPE}" IN_LIST SMCE_LIBRARY_TYPES)
  message (FATAL_ERROR "SMCE_LIBRARY_TYPE must be SHARED or STATIC")
endif ()
string (TOLOWER "${SMCE_LIBRARY_TYPE}" SMCE_PACKAGE_TYPE)

set (SMCE_CXXRT_LINKING "SHARED" CACHE STRING "SHARED to dynamically link against the C++ runtime, or STATIC to link statically")
if (NOT "${SMCE_CXXRT_LINKING}" IN_LIST SMCE_LIBRARY_TYPES)
  message (FATAL_ERROR "SMCE_CXXRT_LINKING must be SHARED or STATIC")
endif ()

set (SMCE_BOOST_LINKING "${SMCE_LIBRARY_TYPE}" CACHE STRING "SHARED to dynamically link against Boost, or STATIC to link statically")
if (NOT "${SMCE_BOOST_LINKING}" IN_LIST SMCE_LIBRARY_TYPES)
  message (FATAL_ERROR "SMCE_BOOST_LINKING must be SHARED or STATIC")
endif ()

option (SMCE_ARDRIVO_MQTT "Set to \"Off\" to disable MQTT integration in Ardrivo" On)

if (SMCE_ARDRIVO_MQTT)
  if (NOT WIN32)
    set (SMCE_MOSQUITTO_LINKING "AUTO" CACHE STRING "AUTO to use the first available library found, or name one of SHARED, STATIC, or SOURCE to force")
    if (NOT "${SMCE_MOSQUITTO_LINKING}" IN_LIST SMCE_EXTENDED_LIBRARY_TYPES)
      message (FATAL_ERROR "SMCE_MOSQUITTO_LINKING must be AUTO, SHARED, STATIC, or SOURCE")
    endif ()
  else ()
    set (SMCE_MOSQUITTO_LINKING "SOURCE" CACHE INTERNAL "" FORCE)
  endif ()

  set (SMCE_OPENSSL_LINKING "${SMCE_LIBRARY_TYPE}" CACHE STRING "SHARED (the default) to dynamically link against OpenSSL, or STATIC to link statically; ignored when SMCE_MOSQUITTO_LINKING is not SOURCE")
  if (NOT "${SMCE_OPENSSL_LINKING}" IN_LIST SMCE_LIBRARY_TYPES)
    message (FATAL_ERROR "SMCE_OPENSSL_LINKING must be SHARED or STATIC")
  endif ()
else ()
  message ("User disabled SMCE_ARDRIVO_MQTT")
endif ()
