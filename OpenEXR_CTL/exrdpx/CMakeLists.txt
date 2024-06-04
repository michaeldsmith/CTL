set( SOURCES
  applyCtl.cpp
  dpxHeader.cpp
  dpxToExr.cpp
  exrToDpx.cpp
  main.cpp
)

add_executable( exrdpx ${SOURCES})

target_include_directories(exrdpx
	PRIVATE
		${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(exrdpx
	PUBLIC
		IlmCtlSimd
		IlmCtlMath
		IlmCtl
		IlmImfCtl
		ctldpx
	# For OpenEXR/Imath 3.x:
    $<$<TARGET_EXISTS:OpenEXR::OpenEXR>:OpenEXR::OpenEXR>
  # For OpenEXR 2.4/2.5:
    $<$<TARGET_EXISTS:OpenEXR::IlmImf>:OpenEXR::IlmImf>
    $<$<TARGET_EXISTS:IlmBase::Imath>:IlmBase::Imath>
    $<$<TARGET_EXISTS:IlmBase::Half>:IlmBase::Half>
    $<$<TARGET_EXISTS:IlmBase::IlmThread>:IlmBase::IlmThread>
    $<$<TARGET_EXISTS:IlmBase::Iex>:IlmBase::Iex> 
)

install( TARGETS exrdpx DESTINATION ${CMAKE_INSTALL_BINDIR} )

install( FILES transform_DPX_EXR.ctl transform_EXR_DPX.ctl DESTINATION ${CMAKE_INSTALL_DATADIR}/CTL )


