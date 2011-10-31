
include(CMakeDependentOption)

#-----------------------------------------------------------------------------
# Build option(s)
#-----------------------------------------------------------------------------
option(USE_BRAINSFit                       "Build BRAINSFit"                       ON)
option(USE_BRAINSROIAuto                   "Build BRAINSROIAuto"                   ON)
option(USE_BRAINSResample                  "Build BRAINSResample"                  ON)
option(USE_GTRACT                          "Build GTRACT"                          ON)

## For now do not build BRAINSDemonWarp unless explicitly requested.
## The conditions where it could be safe to build BRAINSDemonWarp were
## getting overly complicated and was slowing down other tool deployment.
## Someday once BRAINSDemonsWarp becomes trustworthy again, this may be changed.
option(USE_BRAINSDemonWarp "Build BRAINSDemonWarp (ITKv3)" OFF)

set(ITK_VERSION_MAJOR 4 CACHE STRING "Choose the expected ITK major version to build BRAINS (3 or 4).")
# Set the possible values of ITK major version for cmake-gui
set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "3" "4")
if(NOT ${ITK_VERSION_MAJOR} STREQUAL "3" AND NOT ${ITK_VERSION_MAJOR} STREQUAL "4")
  message(FATAL_ERROR "ITK_VERSION_MAJOR should be either 3 or 4")
endif()

set(USE_ITKv3 OFF)
set(USE_ITKv4 ON)
if(${ITK_VERSION_MAJOR} STREQUAL "3")
  set(USE_ITKv3 ON)
  set(USE_ITKv4 OFF)
endif()

CMAKE_DEPENDENT_OPTION(
  USE_BRAINSABC                       "Build BRAINSABC (ITKv4)"                      ON "USE_ITKv4" ON)
CMAKE_DEPENDENT_OPTION(
  USE_BRAINSTransformConvert          "Build BRAINSTransformConvert (ITKv4)"         ON "USE_ITKv4" ON)
CMAKE_DEPENDENT_OPTION(
  USE_BRAINSConstellationDetector     "Build BRAINSConstellationDetector (ITKv4)"    ON "USE_ITKv4" ON)
CMAKE_DEPENDENT_OPTION(
  USE_BRAINSMush                      "Build BRAINSMush (ITKv4)"                     ON "USE_ITKv4" ON)
CMAKE_DEPENDENT_OPTION(
  USE_BRAINSInitializedControlPoints  "Build BRAINSInitializedControlPoints (ITKv4)" ON "USE_ITKv4" ON)
CMAKE_DEPENDENT_OPTION(
  USE_BRAINSMultiModeSegment          "Build BRAINSMultiModeSegment (ITKv4)"        OFF "USE_ITKv4" OFF)
CMAKE_DEPENDENT_OPTION(
  USE_BRAINSCut                       "Build BRAINSCut (ITKv4)"                     OFF "USE_ITKv4" OFF)
CMAKE_DEPENDENT_OPTION(
  USE_ImageCalculator                 "Build ImageCalculator (ITKv4)"               OFF "USE_ITKv4" OFF)

option(USE_DebugImageViewer "Build DebugImageViewer" OFF)

if(DEFINED USE_DebugImageViewer AND USE_DebugImageViewer AND BRAINSTools_USE_QT)
  if(NOT QT4_FOUND)
    find_package(Qt4 COMPONENTS QtCore QtGui QtNetwork REQUIRED)
    include(${QT_USE_FILE})
  endif(NOT QT4_FOUND)
  option(USE_DEBUG_IMAGE_VIEWER "use DebugImageViewer to display intermediate results" OFF)
endif()



#-----------------------------------------------------------------------------
# Update CMake module path
#------------------------------------------------------------------------------
set(CMAKE_MODULE_PATH
  ${${PROJECT_NAME}_SOURCE_DIR}/CMake
  ${${PROJECT_NAME}_BINARY_DIR}/CMake
  ${CMAKE_MODULE_PATH}
  )

#-----------------------------------------------------------------------------
# Sanity checks
#------------------------------------------------------------------------------
include(PreventInSourceBuilds)
include(PreventInBuildInstalls)

#-----------------------------------------------------------------------------
# CMake Function(s) and Macro(s)
#-----------------------------------------------------------------------------
if(CMAKE_PATCH_VERSION LESS 3)
  include(Pre283CMakeParseArguments)
else()
  include(CMakeParseArguments)
endif()

#-----------------------------------------------------------------------------
# Platform check
#-----------------------------------------------------------------------------
set(PLATFORM_CHECK true)

if(PLATFORM_CHECK)
  # See CMake/Modules/Platform/Darwin.cmake)
  #   6.x == Mac OSX 10.2 (Jaguar)
  #   7.x == Mac OSX 10.3 (Panther)
  #   8.x == Mac OSX 10.4 (Tiger)
  #   9.x == Mac OSX 10.5 (Leopard)
  #  10.x == Mac OSX 10.6 (Snow Leopard)
  if (DARWIN_MAJOR_VERSION LESS "9")
    message(FATAL_ERROR "Only Mac OSX >= 10.5 are supported !")
  endif()
endif()

#-----------------------------------------------------------------------------
# Set a default build type if none was specified
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "Setting build type to 'Release' as none was specified.")
  set(CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "Choose the type of build." FORCE)
  # Set the possible values of build type for cmake-gui
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

#-----------------------------------------------------------------------------
if(NOT COMMAND SETIFEMPTY)
  macro(SETIFEMPTY)
    set(KEY ${ARGV0})
    set(VALUE ${ARGV1})
    if(NOT ${KEY})
      set(${ARGV})
    endif()
  endmacro()
endif()

#-----------------------------------------------------------------------------
SETIFEMPTY(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
SETIFEMPTY(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
SETIFEMPTY(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)

#-----------------------------------------------------------------------------
SETIFEMPTY(CMAKE_INSTALL_LIBRARY_DESTINATION lib)
SETIFEMPTY(CMAKE_INSTALL_ARCHIVE_DESTINATION lib)
SETIFEMPTY(CMAKE_INSTALL_RUNTIME_DESTINATION bin)

#-------------------------------------------------------------------------
SETIFEMPTY(BRAINSTools_CLI_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
SETIFEMPTY(BRAINSTools_CLI_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY})
SETIFEMPTY(BRAINSTools_CLI_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})

#-------------------------------------------------------------------------
SETIFEMPTY(BRAINSTools_CLI_INSTALL_LIBRARY_DESTINATION ${CMAKE_INSTALL_LIBRARY_DESTINATION})
SETIFEMPTY(BRAINSTools_CLI_INSTALL_ARCHIVE_DESTINATION ${CMAKE_INSTALL_ARCHIVE_DESTINATION})
SETIFEMPTY(BRAINSTools_CLI_INSTALL_RUNTIME_DESTINATION ${CMAKE_INSTALL_RUNTIME_DESTINATION})

#-------------------------------------------------------------------------
# Augment compiler flags
#-------------------------------------------------------------------------
include(CompilerFlagSettings)
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${C_DEBUG_DESIRED_FLAGS}" )
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CXX_DEBUG_DESIRED_FLAGS}" )
else() # Release, or anything else
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${C_RELEASE_DESIRED_FLAGS}" )
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CXX_RELEASE_DESIRED_FLAGS}" )
endif()

#-----------------------------------------------------------------------------
# Add needed flag for gnu on linux like enviroments to build static common libs
# suitable for linking with shared object libs.
if(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
  if(NOT "${CMAKE_CXX_FLAGS}" MATCHES "-fPIC")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")
  endif()
  if(NOT "${CMAKE_C_FLAGS}" MATCHES "-fPIC")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")
  endif()
endif()

