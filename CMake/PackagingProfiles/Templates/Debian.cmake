#
#  PackagingProfiles/Templates/Debian.cmake
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

set (CPACK_GENERATOR DEB)
set (CPACK_DEBIAN_PACKAGE_SHLIBDEPS On)
set (CPACK_DEBIAN_PACKAGE_GENERATE_SHLIBS Off)

set (CPACK_DEBIAN_FILE_NAME DEB-DEFAULT)
set (CPACK_DEBIAN_PACKAGE_NAME "smce_gd")
set (CPACK_DEBIAN_PACKAGE_RELEASE "${SMCE_OS_RELEASE}.${SMCE_PROFILE_VERSION}")
set (CPACK_DEBIAN_PACKAGE_SECTION "embedded")
set (CPACK_DEBIAN_PACKAGE_PRIORITY "optional")
set (CPACK_DEBIAN_COMPRESSION_TYPE "xz")
set (CPACK_DEBIAN_PACKAGE_DESCRIPTION "An emulated environment for Arduino-based vehicles; primarily designed for use with the smartcar_shield library.")
set (CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${PROJECT_SOURCE_DIR}/debian/postinst" "${PROJECT_SOURCE_DIR}/debian/postrm")
