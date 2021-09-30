#
#  LegacyPreprocessing.cmake
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

## Expected variables:
# COMP_DIR - sketch build dir
# SKETCH_FQBN - Fully qualified board name to use
# SKETCH_PATH - Path to the Arduino sketch

cmaw_preprocess (PREPROCD_SKETCH "${SKETCH_FQBN}" "${SKETCH_PATH}")
if ("${PREPROCD_SKETCH}" STREQUAL "")
  message (FATAL_ERROR "Preprocessing failed")
endif ()
set (COMP_SRC "${COMP_DIR}/sketch.cpp")
file (WRITE "${COMP_SRC}" "${PREPROCD_SKETCH}")
