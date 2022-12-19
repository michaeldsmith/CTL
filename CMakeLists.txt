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
    find_package(IlmBase QUIET)
  endif()
  if(IlmBase_FOUND)
    message( STATUS "found IlmBase, version ${IlmBase_VERSION}" )
    ###
    ### Everyone (well, except for DPX) uses IlmBase, so
    ### make that a global setting
    ###
    include_directories( ${IlmBase_INCLUDE_DIRS} )
    link_directories( ${IlmBase_LIBRARY_DIRS} )
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${IlmBase_CFLAGS}" )
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${IlmBase_CFLAGS}" )
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${IlmBase_LDFLAGS}" )
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${IlmBase_LDFLAGS}" )
    set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} ${IlmBase_LDFLAGS}" )
  else()
    message( SEND_ERROR "IlmBase not found, please set the include and library paths manually" )
  endif()
endif ()

if(IlmBase_FOUND)
  find_package(OpenEXR QUIET CONFIG)
else()
  find_package(OpenEXR QUIET CONFIG REQUIRED)
endif()

add_subdirectory(lib)
add_subdirectory(doc)
if (CTL_BUILD_TOOLS)
	add_subdirectory(ctlrender)
endif()

if (CTL_BUILD_TESTS)
	add_subdirectory(unittest)
endif()

