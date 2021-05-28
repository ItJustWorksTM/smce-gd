#
#  Resources.cmake
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

macro (setup_smce_resources)
  set (SMCE_RTRES_DIR "${PROJECT_BINARY_DIR}/RtResources")
  file (REMOVE_RECURSE "${SMCE_RTRES_DIR}")
  file (MAKE_DIRECTORY "${SMCE_RTRES_DIR}")

  file (MAKE_DIRECTORY "${SMCE_RTRES_DIR}/SMCE/share")
  file (COPY "${PROJECT_SOURCE_DIR}/CMake/Runtime" DESTINATION "${SMCE_RTRES_DIR}/SMCE/share")
  file (COPY "${PROJECT_SOURCE_DIR}/CMake/Scripts" DESTINATION "${SMCE_RTRES_DIR}/SMCE/share")

  file (MAKE_DIRECTORY "${SMCE_RTRES_DIR}/Ardrivo")
  file (MAKE_DIRECTORY "${SMCE_RTRES_DIR}/Ardrivo/bin")
  file (MAKE_DIRECTORY "${SMCE_RTRES_DIR}/Ardrivo/share")

  file (COPY "${PROJECT_SOURCE_DIR}/share/Ardrivo/sketch_main.cpp" DESTINATION "${SMCE_RTRES_DIR}/Ardrivo/share")

  set (SMCE_RESOURCES_ARK "${PROJECT_BINARY_DIR}/SMCE_Resources.zip")
  file (GENERATE
      OUTPUT "${SMCE_RTRES_DIR}/Ardrivo/share/ArdrivoOutputNames.cmake"
      CONTENT
      [[
        #HSD Generated
        set (ARDRIVO_FILE_NAME "$<TARGET_FILE_NAME:Ardrivo>")
        set (ARDRIVO_LINKER_FILE_NAME "$<TARGET_LINKER_FILE_NAME:Ardrivo>")
      ]]
  )
  add_custom_command (OUTPUT "${SMCE_RESOURCES_ARK}"
      COMMAND "${CMAKE_COMMAND}" -E copy "$<TARGET_FILE:Ardrivo>" "${SMCE_RTRES_DIR}/Ardrivo/bin"
      COMMAND "${CMAKE_COMMAND}" -E copy "$<TARGET_LINKER_FILE:Ardrivo>" "${SMCE_RTRES_DIR}/Ardrivo/bin"
      COMMAND "${CMAKE_COMMAND}" -E tar cf "${SMCE_RESOURCES_ARK}" --format=zip -- "${SMCE_RTRES_DIR}"
      DEPENDS
      Ardrivo
      "${PROJECT_SOURCE_DIR}/CMake/Runtime/CMakeLists.txt"
      "${PROJECT_SOURCE_DIR}/CMake/Scripts/ConfigureSketch.cmake"
      "${PROJECT_SOURCE_DIR}/share/Ardrivo/sketch_main.cpp"
  )

  file (MAKE_DIRECTORY "${SMCE_RTRES_DIR}/Ardrivo/include")
  file (COPY "${PROJECT_SOURCE_DIR}/include/Ardrivo" DESTINATION "${SMCE_RTRES_DIR}/Ardrivo/include")

  add_custom_target (ArdRtRes DEPENDS "${SMCE_RESOURCES_ARK}")
endmacro ()
