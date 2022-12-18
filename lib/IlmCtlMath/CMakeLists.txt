set(SOURCES
	CtlColorSpace.cpp
	CtlLookupTable.cpp
	CtlRbfInterpolator.cpp
)

target_link_libraries( IlmCtlMath IlmCtl )

set_target_properties(IlmCtlMath
	PROPERTIES
		VERSION ${CTL_VERSION}
		SOVERSION ${CTL_VERSION}
)

install(FILES
	CtlColorSpace.h
	CtlLookupTable.h
	CtlRbfInterpolator.h
	CtlSparseMatrix.h
DESTINATION
	${CMAKE_INSTALL_INCLUDEDIR}/CTL
)

install(TARGETS IlmCtlMath DESTINATION ${CMAKE_INSTALL_LIBDIR})
