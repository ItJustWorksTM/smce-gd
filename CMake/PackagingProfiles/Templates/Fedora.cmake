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
set (CPACK_COMPONENTS_GROUPING ONE_PER_GROUP)
set (CPACK_RPM_COMPONENT_INSTALL On)
set (CPACK_RPM_PACKAGE_AUTOREQPROV On)
set (CPACK_RPM_MAIN_COMPONENT main)
# set (CPACK_COMPONENT_DEVEL_DEPENDS "main")
# set (CPACK_COMPONENT_STATIC_DEPENDS "devel")

set (CPACK_RPM_FILE_NAME RPM-DEFAULT)
set (CPACK_RPM_PACKAGE_RELEASE "${SMCE_PROFILE_VERSION}")
set (CPACK_RPM_PACKAGE_RELEASE_DIST "${SMCE_OS_RELEASE}")
set (CPACK_RPM_PACKAGE_LICENSE "ASL 2.0")
set (CPACK_RPM_PACKAGE_VENDOR "${CPACK_PACKAGE_CONTACT}")
set (CPACK_RPM_BUILDREQUIRES "cmake >= 3.16, git >= 2.20, gcc-c++ >= 10.0, boost-devel >= 1.74, openssl-devel >= 1.1.1")
set (CPACK_COMPONENT_MAIN_DESCRIPTION "${CPACK_PACKAGE_DESCRIPTION}\n\nThis package provides the runtime resources.")
set (CPACK_COMPONENT_DEVEL_DESCRIPTION "${CPACK_PACKAGE_DESCRIPTION}\n\nThis package provides the development resources.")
set (CPACK_COMPONENT_STATIC_DESCRIPTION "${CPACK_PACKAGE_DESCRIPTION}\n\nThis package provides the static library.")
file (WRITE "${PROJECT_BINARY_DIR}/rpm-postin.sh" "#!/bin/sh\nldconfig")
file (WRITE "${PROJECT_BINARY_DIR}/rpm-postun.sh" "#!/bin/sh\nldconfig")
set (CPACK_RPM_POST_INSTALL_SCRIPT_FILE "${PROJECT_BINARY_DIR}/rpm-postin.sh")
set (CPACK_RPM_POST_UNINSTALL_SCRIPT_FILE "${PROJECT_BINARY_DIR}/rpm-postun.sh")
if (DEFINED SMCE_BUILD_PROFILE)
  set (CPACK_RPM_SOURCE_PKG_BUILD_PARAMS "-DSMCE_BUILD_PROFILE=${SMCE_BUILD_PROFILE}")
endif ()

# Workaround buggy CPackRPM
string (TOLOWER "${PROJECT_NAME}" PROJECT_NAME_LC)
string (REPLACE "_" "-" SYSPROC_DASHED "${CMAKE_SYSTEM_PROCESSOR}")
set (SMCE_RPM_PKG_VERSION "${PROJECT_VERSION}-${CPACK_RPM_PACKAGE_RELEASE}${CPACK_RPM_PACKAGE_RELEASE_DIST}")
set (CPACK_RPM_DEVEL_PACKAGE_REQUIRES "${PROJECT_NAME_LC}(${SYSPROC_DASHED}) = ${SMCE_RPM_PKG_VERSION}")
set (CPACK_RPM_STATIC_PACKAGE_REQUIRES "${PROJECT_NAME_LC}-devel(${SYSPROC_DASHED}) = ${SMCE_RPM_PKG_VERSION}")
