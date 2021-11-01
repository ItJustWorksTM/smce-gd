#
#  PackagingProfiles/WiX.cmake
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

set (CPACK_GENERATOR WIX)
set (CPACK_WIX_UPGRADE_GUID 0602a6db-61aa-4440-80f9-547cec5db5b9)
set (CPACK_WIX_ROOT_FEATURE_TITLE "SMCE Godot")
set (CPACK_WIX_PRODUCT_ICON "${PROJECT_SOURCE_DIR}/project/media/images/icon.png")
