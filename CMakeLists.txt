cmake_minimum_required(VERSION 3.1)
project(CTL VERSION 1.5.2)
enable_testing()
include(GNUInstallDirs)

set(CMAKE_MODULE_PATH
	"${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules"
	${CMAKE_MODULE_PATH}
)

option(CTL_BUILD_TESTS "Build the unit tests" ON)
option(CTL_BUILD_TOOLS "Build the utility commands (ctlrender, etc)" ON)

set(CMAKE_CXX_FLAGS_ASAN
  "-fsanitize=address -fno-optimize-sibling-calls -fsanitize-address-use-after-scope -fno-omit-frame-pointer -g -O1"
  CACHE STRING "Flags used by the C++ compiler during AddressSanitizer builds."
  FORCE)

if( NOT DEFINED CMAKE_BUILD_TYPE )
  MESSAGE( STATUS "To use AddressSanitizer, use \"cmake .. -DCMAKE_BUILD_TYPE=asan\"" )
elseif( CMAKE_BUILD_TYPE STREQUAL "asan" )
  MESSAGE( STATUS "Using AddressSanitizer - CMAKE_BUILD_TYPE : \"${CMAKE_BUILD_TYPE}\"")
else()
  MESSAGE( STATUS "CMAKE_BUILD_TYPE : \"${CMAKE_BUILD_TYPE}\"")
  MESSAGE( STATUS "To use AddressSanitizer, use \"cmake .. -DCMAKE_BUILD_TYPE=asan\"" )
endif()

find_package(Imath CONFIG)

if (NOT TARGET Imath::Imath)
  message( STATUS " Couldn't find Imath::Imath, maybe it's older and has IlmBase?")
  find_package(IlmBase CONFIG)
  if(NOT IlmBase_FOUND)
    message( STATUS " Couldn't find IlmBase with find_package(IlmBase CONFIG), trying find_package(IlmBase QUIET)")
    find_package(IlmBase QUIET)
  endif()
  if( IlmBase_FOUND)
    message( STATUS "found IlmBase, version ${IlmBase_VERSION}" )
  else()
    message( SEND_ERROR "IlmBase not found, please set the include and library paths manually" )
  endif()
else()
  message( STATUS "found Imath, version ${Imath_VERSION}" )
  find_package(IlmBase CONFIG)
  if(NOT IlmBase_FOUND)
    find_package(IlmBase QUIET)
  endif()
  if( IlmBase_FOUND)
    message( STATUS "found IlmBase, version ${IlmBase_VERSION}" )
  endif()
endif ()

if(IlmBase_FOUND)
  message( STATUS "IlmBase_INCLUDE_DIRS : ${IlmBase_INCLUDE_DIRS}" )
  find_package(OpenEXR QUIET CONFIG)
else()
  find_package(OpenEXR QUIET CONFIG REQUIRED)
endif()

if( OpenEXR_FOUND )
  message( STATUS "found OpenEXR, version ${OpenEXR_VERSION}" )
else()
  message( STATUS "OpenEXR not found" )
  #find_package(Threads)
endif()

add_subdirectory(lib)
add_subdirectory(doc)
if (CTL_BUILD_TOOLS)
	add_subdirectory(ctlrender)
endif()

if (CTL_BUILD_TESTS)
	add_subdirectory(unittest)
endif()

