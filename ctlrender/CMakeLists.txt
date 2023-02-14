set(SOURCES
	main.cc
	transform.cc
	usage.cc
	aces_file.cc
	dpx_file.cc
	exr_file.cc
	tiff_file.cc
	format.cc
	compression.cc
)
add_executable(ctlrender ${SOURCES})
target_include_directories(ctlrender
	PRIVATE
		${CMAKE_CURRENT_SOURCE_DIR}
)
target_link_libraries(ctlrender
	PRIVATE
		IlmCtlSimd
		IlmCtlMath
		IlmCtl
		ctldpx
	    # For OpenEXR/Imath 3.x:
          $<$<TARGET_EXISTS:OpenEXR::OpenEXR>:OpenEXR::OpenEXR>
        # For OpenEXR 2.4/2.5:
          $<$<TARGET_EXISTS:OpenEXR::IlmImf>:OpenEXR::IlmImf>
)

if( OpenEXR_FOUND )
	target_compile_definitions(ctlrender
	PRIVATE
		-DHAVE_OPENEXR=1
	)
else()
	message( STATUS "OPENEXR not found, ctlrender will not support EXR files" )
endif()

find_package(TIFF)
if(TARGET TIFF::TIFF)
	message( STATUS "found TIFF, TIFF_LIBRARIES : ${TIFF_LIBRARIES}" )
	target_compile_definitions(ctlrender
		PRIVATE
			-DHAVE_LIBTIFF=1
	)
	target_link_libraries(ctlrender
		PRIVATE
			TIFF::TIFF
	)
else()
	message( STATUS "TIFF not found, ctlrender will not support TIF files" )
endif()

#set(AcesContainer_DIR "/usr/local/lib/CMake/AcesContainer/" CACHE PATH "AcesContainerConfig.cmake")

find_package(AcesContainer)
if (TARGET AcesContainer::AcesContainer)
	target_compile_definitions(ctlrender
		PRIVATE
			-DHAVE_ACESFILE=1
	)
	target_link_libraries(ctlrender
		PRIVATE
			AcesContainer::AcesContainer
	)
	message( STATUS "AcesContainer found, ctlrender will include support for writing ACES (SMPTE ST2065-4) files" )
else()
	message( STATUS "AcesContainer not found, ctlrender will not support writing ACES (SMPTE ST2065-4) files" )
endif()



# find_package( AcesContainer )
# if (AcesContainer_FOUND)
#   message( STATUS "Found AcesContainer, version ${AcesContainer_VERSION}" )
# # else()
# #   if ( PKG_CONFIG_FOUND )
# #     pkg_check_modules( AcesContainer AcesContainer )
# #   else()
# #     message( WARNING "Unable to find AcesContainer libraries, disabling" )
# #   endif()

# add_definitions( -DHAVE_ACESFILE=1 )
# include_directories( ${AcesContainer_INCLUDE_DIRS} )
# link_directories( ${AcesContainer_LIBRARY_DIRS} )

# message( STATUS "AcesContainer_INCLUDE_DIRS : ${AcesContainer_INCLUDE_DIRS}" )
# message( STATUS "AcesContainer_LIBRARY_DIRS : ${AcesContainer_LIBRARY_DIRS}" )

# 	message( STATUS "AcesContainer found, ctlrender will include support for writing ACES (SMPTE ST2065-4) files" )
# else()
# 	message( STATUS "AcesContainer not found, ctlrender will not support writing ACES (SMPTE ST2065-4) files" )
# endif()

install(TARGETS ctlrender DESTINATION ${CMAKE_INSTALL_BINDIR})
