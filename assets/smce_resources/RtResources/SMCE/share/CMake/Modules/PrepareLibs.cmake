#
#  PrepareLibs.cmake
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
# PREPROC_REMOTE_LIBS - whitespace-separated of remote libs to pull for preprocessing
# COMPLINK_REMOTE_LIBS - remote libs needed at compile/link-time
# COMPLINK_PATCH_LIBS - remote libs to patch for compile/link-time

file (MAKE_DIRECTORY "${COMP_DIR}/libs")
foreach (COMPLINK_PATCH_LIB ${COMPLINK_PATCH_LIBS})
  string (REGEX MATCH "^([^|]+)\\|([^@]*)(@?[0-9.]*)$" MATCH "${COMPLINK_PATCH_LIB}")
  if (NOT MATCH)
    message (FATAL_ERROR "Invalid COMPLINK_PATCH_LIB (\"${COMPLINK_PATCH_LIB}\")")
  endif ()
  set (COMPLINK_PATCH_LIB_PATH "${CMAKE_MATCH_1}")
  string (REPLACE " " "_" COMPLINK_PATCH_LIB_TARGET "${CMAKE_MATCH_2}")

  message (STATUS "Processing library \"${COMPLINK_PATCH_LIB_TARGET}\" (patched by \"${COMPLINK_PATCH_LIB_PATH}\")")
  # Copy original library
  file (COPY "${ARDCLI_CONFIG_USERDIR}/libraries/${COMPLINK_PATCH_LIB_TARGET}" DESTINATION "${COMP_DIR}/libs")

  # Merge-in the patch tree
  file (GLOB_RECURSE COMPLINK_PATCH_LIB_FILEPATHS
      LIST_DIRECTORIES false RELATIVE "${COMPLINK_PATCH_LIB_PATH}"
      "${COMPLINK_PATCH_LIB_PATH}/*")
  foreach (COMPLINK_PATCH_LIB_RELFILEPATH ${COMPLINK_PATCH_LIB_FILEPATHS})
    if (${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.20")
      cmake_path (GET COMPLINK_PATCH_LIB_RELFILEPATH PARENT_PATH COMPLINK_PATCH_LIB_RELFILEDIR)
    else ()
      get_filename_component (COMPLINK_PATCH_LIB_RELFILEDIR "${COMPLINK_PATCH_LIB_RELFILEPATH}" DIRECTORY)
    endif ()
    file (MAKE_DIRECTORY "${COMP_DIR}/libs/${COMPLINK_PATCH_LIB_TARGET}/${COMPLINK_PATCH_LIB_RELFILEDIR}")
    file (COPY "${COMPLINK_PATCH_LIB_PATH}/${COMPLINK_PATCH_LIB_RELFILEPATH}" DESTINATION "${COMP_DIR}/libs/${COMPLINK_PATCH_LIB_TARGET}/${COMPLINK_PATCH_LIB_RELFILEDIR}")
  endforeach ()
endforeach ()
