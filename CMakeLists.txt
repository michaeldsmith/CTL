cmake_minimum_required(VERSION 3.1)
project(CTL VERSION 1.5.1)
enable_testing()
include(GNUInstallDirs)

set(CMAKE_MODULE_PATH
	"${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules"
	${CMAKE_MODULE_PATH}
)

option(CTL_BUILD_TESTS "Build the unit tests" OFF)
option(CTL_BUILD_TOOLS "Build the utility commands (ctlrender, etc)" ON)

# use, i.e. don't skip the full RPATH for the build tree
SET(CMAKE_SKIP_BUILD_RPATH  FALSE)
# when building, don't use the install RPATH already
# (but later on when installing)
SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE) 
#SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
# add the automatically determined parts of the RPATH
# which point to directories outside the build tree to the install RPATH
SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
# the RPATH to be used when installing, but only if it's not a system directory
LIST(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/lib" isSystemDir)
IF("${isSystemDir}" STREQUAL "-1")
  SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
ENDIF("${isSystemDir}" STREQUAL "-1")


## convert install paths to absolute
foreach( p LIB BIN INCLUDE CMAKE DOC)
  set( var INSTALL_${p}_DIR )
  if( NOT IS_ABSOLUTE "${${var}}" )
    set( ${var} "${CMAKE_INSTALL_PREFIX}/${${var}}" )
  endif()
endforeach()

option(ENABLE_SHARED "Enable Shared Libraries" ON)

if ( ENABLE_SHARED )
set( DO_SHARED SHARED )
else()
set( DO_SHARED STATIC )
endif()

# Find packages and set up global settings
include( configure.cmake )

# generated config files end up in binary dir so to find them, need
# to add to include path
include_directories( "${PROJECT_SOURCE_DIR}" "${PROJECT_BINARY_DIR}" )
# implement find library stuff...

add_definitions( -DPACKAGE="CTL" -DVERSION="${CTL_VERSION}" )
add_subdirectory(doc)
if (CTL_BUILD_TOOLS)
	add_subdirectory(ctlrender)
endif()

if (CTL_BUILD_TESTS)
	add_subdirectory(unittest)
endif()

