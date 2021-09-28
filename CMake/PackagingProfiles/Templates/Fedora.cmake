#
#  PackagingProfiles/Templates/Fedora.cmake
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

if (NOT DEFINED SMCE_OS_RELEASE)
  set (SMCE_OS_RELEASE "custom")
endif ()

set (CPACK_GENERATOR RPM)
set (CPACK_SOURCE_GENERATOR RPM)
set (CPACK_RPM_PACKAGE_AUTOREQPROV On)

set (CPACK_RPM_FILE_NAME RPM-DEFAULT)
set (CPACK_RPM_PACKAGE_RELEASE "${SMCE_PROFILE_VERSION}")
set (CPACK_RPM_PACKAGE_RELEASE_DIST "${SMCE_OS_RELEASE}")
set (CPACK_RPM_PACKAGE_LICENSE "ASL 2.0")
set (CPACK_RPM_PACKAGE_VENDOR "${CPACK_PACKAGE_CONTACT}")
set (CPACK_RPM_BUILDREQUIRES "cmake >= 3.17, git >= 2.20, gcc-c++ >= 10.0, libsmce-devel = 1.4")
if (DEFINED SMCE_BUILD_PROFILE)
  set (CPACK_RPM_SOURCE_PKG_BUILD_PARAMS "-DSMCE_BUILD_PROFILE=${SMCE_BUILD_PROFILE}")
endif ()

# Prevent stripping of smce_gd
set (CPACK_RPM_SPEC_MORE_DEFINE "%define __spec_install_post /bin/true")
