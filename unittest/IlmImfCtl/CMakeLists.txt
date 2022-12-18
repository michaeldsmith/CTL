
include_directories( ${OpenEXR_INCLUDE_DIRS} )
link_directories( ${OpenEXR_LIBRARY_DIRS} )

include_directories( "${CMAKE_CURRENT_SOURCE_DIR}"
                     "${PROJECT_SOURCE_DIR}/lib/IlmCtl" 
                     "${PROJECT_SOURCE_DIR}/lib/IlmCtlMath" 
                     "${PROJECT_SOURCE_DIR}/lib/IlmCtlSimd" 
                     "${PROJECT_SOURCE_DIR}/lib/IlmImfCtl" )
                     

add_executable(IlmImfCtlTest
    main.cpp
    testSourceDestination.cpp
    testTypes.cpp
)

add_executable(IlmImfCtlTest ${SOURCES})

target_include_directories(IlmImfCtlTest
	PRIVATE
		${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries( IlmImfCtlTest
	PRIVATE
		IlmImfCtl
		IlmCtlSimd
		IlmCtlMath
		IlmCtl
)

add_test( IlmImfCtl IlmImfCtlTest )

file(COPY
    function1.ctl
    function2.ctl
    function3.ctl
DESTINATION
	${CMAKE_CURRENT_BINARY_DIR}
)
