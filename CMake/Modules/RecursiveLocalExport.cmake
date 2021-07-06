#
#  RecursiveLocalExport.cmake
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

function (recursive_local_export)
  cmake_parse_arguments (RECURSIVE_LOCAL_EXPORT "" "NAMESPACE" "TARGETS" ${ARGV})
  if (NOT DEFINED RECURSIVE_LOCAL_EXPORT_TARGETS)
    message (FATAL_ERROR "TARGETS argument required")
  endif ()

  set (PENDING_TARGETS ${RECURSIVE_LOCAL_EXPORT_TARGETS})
  set (PROCESSED_TARGETS)
  return ()
  while (NOT PENDING_TARGETS STREQUAL "")
    message ("PENDING_TARGETS: ${PENDING_TARGETS}")
    set (PENDING_LIBS)
    list (POP_FRONT PENDING_TARGETS CURRENT_TARGET)

    get_target_property (TGT_IMP "${CURRENT_TARGET}" IMPORTED)
    if (TGT_IMP)
      continue ()
    endif ()

    get_target_property (TGT_TYPE "${CURRENT_TARGET}" TYPE)
    if ("${TGT_TYPE}" STREQUAL "INTERFACE_LIBRARY")
      set (TGT_IFACE Yes)
    else ()
      set (TGT_IFACE No)
    endif ()

    if (NOT TGT_IFACE)
      get_target_property (TGT_LINK_LIBS "${CURRENT_TARGET}" LINK_LIBRARIES)
    endif ()
    get_target_property (TGT_LINK_IFACE_LIBS "${CURRENT_TARGET}" INTERFACE_LINK_LIBRARIES)
    list (APPEND PENDING_LIBS ${TGT_LINK_LIBS} ${TGT_LINK_IFACE_LIBS})

    foreach (CONF ${CMAKE_CONFIGURATION_TYPES})
      if (NOT TGT_IFACE)
        get_target_property (TGT_LINK_LIBS_CFG "${CURRENT_TARGET}" LINK_LIBRARIES_${CONF})
      endif ()
      get_target_property (TGT_LINK_IFACE_LIBS_CFG "${CURRENT_TARGET}" INTERFACE_LINK_LIBRARIES_${CONF})
      list (APPEND PENDING_LIBS ${TGT_LINK_LIBS_CFG} ${TGT_LINK_IFACE_LIBS_CFG})
    endforeach ()

    list (SORT PENDING_LIBS)
    list (REMOVE_DUPLICATES PENDING_LIBS)

    foreach (LIB ${PENDING_LIBS})
      if (TARGET "${LIB}")
        list (FIND PROCESSED_TARGETS "${LIB}" LIB_PROCESSED_IDX)
        if (LIB_PROCESSED_IDX EQUAL -1)
          list (APPEND PENDING_TARGETS "${LIB}")
        endif ()
      endif ()
    endforeach ()
    list (APPEND PROCESSED_TARGETS "${CURRENT_TARGET}")

    list (SORT PENDING_TARGETS)
    list (REMOVE_DUPLICATES PENDING_TARGETS)
  endwhile ()

  export (TARGETS ${PROCESSED_TARGETS} NAMESPACE ${RECURSIVE_LOCAL_EXPORT_NAMESPACE} ${RECURSIVE_LOCAL_EXPORT_UNPARSED_ARGUMENTS})
endfunction ()
