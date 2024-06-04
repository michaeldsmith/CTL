set( SOURCES
  applyCtl.cpp
  applyCtl.h
  exrCtlExr.cpp
  exrCtlExr.h
  main.cpp
)

add_executable( exr_ctl_exr ${SOURCES})

target_include_directories(exr_ctl_exr
	PRIVATE
		${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries (exr_ctl_exr
  PUBLIC
		IlmCtlSimd 
		IlmCtlMath 
		IlmCtl 
		IlmImfCtl
    ctldpx
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
)

install( TARGETS exr_ctl_exr DESTINATION ${CMAKE_INSTALL_BINDIR} )

install( FILES change_saturation.ctl DESTINATION ${CMAKE_INSTALL_DATADIR}/CTL )
