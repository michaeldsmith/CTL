
include_directories( ${OpenEXR_INCLUDE_DIRS} )
link_directories( ${OpenEXR_LIBRARY_DIRS} )

include_directories( "${CMAKE_CURRENT_SOURCE_DIR}" 
                     "${PROJECT_SOURCE_DIR}/lib/IlmCtl" 
                     "${PROJECT_SOURCE_DIR}/lib/IlmCtlMath" 
                     "${PROJECT_SOURCE_DIR}/lib/IlmCtlSimd" 
                     "${PROJECT_SOURCE_DIR}/lib/IlmImfCtl" )

add_executable( exr_ctl_exr
	applyCtl.cpp
	applyCtl.h
	exrCtlExr.cpp
	exrCtlExr.h
	main.cpp
)

#target_link_libraries( exr_ctl_exr IlmCtlSimd IlmCtlMath IlmCtl IlmImfCtl )
target_link_libraries (exr_ctl_exr
    PRIVATE
		IlmCtlSimd 
		IlmCtlMath 
		IlmCtl 
		IlmImfCtl
        # For OpenEXR/Imath 3.x:
          $<$<TARGET_EXISTS:OpenEXR::OpenEXR>:OpenEXR::OpenEXR>
          $<$<TARGET_EXISTS:Imath::Imath>:Imath::Imath>
          $<$<TARGET_EXISTS:Imath::Half>:Imath::Half>
        # For OpenEXR 2.4/2.5:
          $<$<TARGET_EXISTS:OpenEXR::IlmImf>:OpenEXR::IlmImf>
          $<$<TARGET_EXISTS:IlmBase::Imath>:IlmBase::Imath>
          $<$<TARGET_EXISTS:IlmBase::Half>:IlmBase::Half>
          $<$<TARGET_EXISTS:IlmBase::IlmThread>:IlmBase::IlmThread>
          $<$<TARGET_EXISTS:IlmBase::Iex>:IlmBase::Iex>
        # ZLIB for OpenEXR 2.x:
	  	    $<$<TARGET_EXISTS:ZLIB::ZLIB>:ZLIB::ZLIB>
    )
#target_link_libraries( exr_ctl_exr ${IlmBase_LIBRARIES} ${IlmBase_LDFLAGS_OTHER} )
#target_link_libraries( exr_ctl_exr ${OpenEXR_LIBRARIES} ${OpenEXR_LDFLAGS_OTHER} )

install( TARGETS exr_ctl_exr DESTINATION ${CMAKE_INSTALL_BINDIR} )

install( FILES change_saturation.ctl DESTINATION ${CMAKE_INSTALL_DATADIR}/CTL )
