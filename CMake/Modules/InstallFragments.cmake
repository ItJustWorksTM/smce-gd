#
#  Modules/InstallFragments.cmake
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

include (GNUInstallDirs)

set (SMCE_BOILERPLATE_TARGETS objSMCE ipcSMCE iSMCE)

function (smce_internal_install TARGETS)
  cmake_parse_arguments (SMCE_INSTALL "" "COMPONENT" "TARGETS" ${ARGV})
  if (DEFINED SMCE_INSTALL_COMPONENT)
    set (SMCE_INSTALL_COMPONENT_ARG COMPONENT "${SMCE_INSTALL_COMPONENT}")
  else ()
    set (SMCE_INSTALL_COMPONENT_ARG)
  endif ()
  install (TARGETS ${SMCE_INSTALL_TARGETS}
      EXPORT SMCETargets
      ${SMCE_INSTALL_COMPONENT_ARG}
      ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
      LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
      RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
      INCLUDES DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/SMCE"
    )
endfunction ()

function (smce_install_boilerplate_targets)
  cmake_parse_arguments (SMCE_INSTALL "" "COMPONENT" "" ${ARGV})
  if (DEFINED SMCE_INSTALL_UNPARSED_ARGUMENTS)
    message (FATAL_ERROR "Extraneous arguments: ${SMCE_INSTALL_UNPARSED_ARGUMENTS}")
  endif ()
  if (DEFINED SMCE_INSTALL_COMPONENT)
    set (SMCE_INSTALL_COMPONENT COMPONENT "${SMCE_INSTALL_COMPONENT}")
  endif ()
  smce_internal_install (TARGETS "${SMCE_BOILERPLATE_TARGETS}" ${SMCE_INSTALL_COMPONENT})
endfunction ()

function (smce_install)
  cmake_parse_arguments (SMCE_INSTALL "" "COMPONENT" "TARGETS" ${ARGV})
  if (DEFINED SMCE_INSTALL_UNPARSED_ARGUMENTS)
    message (FATAL_ERROR "Extraneous arguments: ${SMCE_INSTALL_UNPARSED_ARGUMENTS}")
  endif ()
  if (NOT DEFINED SMCE_INSTALL_TARGETS)
    message (FATAL_ERROR "No targets passed to command smce_install")
  endif ()
  if (DEFINED SMCE_INSTALL_COMPONENT)
    set (SMCE_INSTALL_COMPONENT_ARG COMPONENT "${SMCE_INSTALL_COMPONENT}")
  endif ()
  smce_internal_install (${ARGV})
endfunction ()

include (RecursiveLocalExport)

function (smce_internal_export)
  cmake_parse_arguments (SMCE_EXPORT "" "" "TARGETS" ${ARGV})
  if (DEFINED SMCE_EXPORT_UNPARSED_ARGUMENTS)
    message (AUTHOR_WARNING "Extraneous arguments: ${SMCE_EXPORT_UNPARSED_ARGUMENTS}")
  endif ()
  recursive_local_export (TARGETS ${SMCE_EXPORT_TARGETS} NAMESPACE SMCE:: APPEND
      FILE "${PROJECT_BINARY_DIR}/cmake/SMCETargets.cmake"
      EXPORT_LINK_INTERFACE_LIBRARIES
  )
endfunction ()

function (smce_export)
  cmake_parse_arguments (SMCE_EXPORT "" "" "TARGETS" ${ARGV})
  if (DEFINED SMCE_EXPORT_UNPARSED_ARGUMENTS)
    message (FATAL_ERROR "Extraneous arguments: ${SMCE_EXPORT_UNPARSED_ARGUMENTS}")
  endif ()
  if (NOT DEFINED SMCE_EXPORT_TARGETS)
    message (FATAL_ERROR "No targets passed to command smce_export")
  endif ()
  smce_internal_export (${ARGV})
endfunction ()

macro (smce_install_config)
  include (CMakePackageConfigHelpers)

  write_basic_package_version_file ("${PROJECT_BINARY_DIR}/SMCEConfigVersion.cmake"
      VERSION "${PROJECT_VERSION}"
      COMPATIBILITY AnyNewerVersion
  )
  configure_package_config_file ("${PROJECT_SOURCE_DIR}/Config.cmake.in"
      "${PROJECT_BINARY_DIR}/SMCEConfig.cmake"
      INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/SMCE"
  )

  install (FILES
      "${PROJECT_BINARY_DIR}/SMCEConfig.cmake"
      "${PROJECT_BINARY_DIR}/SMCEConfigVersion.cmake"
      DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/SMCE"
  )
endmacro ()
