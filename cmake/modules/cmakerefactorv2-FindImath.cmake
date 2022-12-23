# Module to find Imath 

find_package(Imath QUIET CONFIG)
if (NOT TARGET Imath::Imath)
	# Maybe an older version of IlmBase exists?
	find_package(IlmBase QUIET CONFIG)
	if(TARGET IlmBase::Imath)
		add_library(Imath::Imath ALIAS IlmBase::Imath)
	endif()
endif()

if(TARGET Imath::Imath)
	return()
endif()