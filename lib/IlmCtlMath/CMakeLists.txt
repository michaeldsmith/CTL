include_directories( "${CMAKE_CURRENT_SOURCE_DIR}" "${PROJECT_SOURCE_DIR}/lib/IlmCtl" )

add_library( IlmCtlMath ${DO_SHARED}
  CtlColorSpace.cpp
  CtlLookupTable.cpp
  CtlRbfInterpolator.cpp
)

target_link_libraries( IlmCtlMath IlmCtl )
target_link_libraries( IlmCtlMath Imath )
if ( NOT OpenEXR_FOUND )
  target_link_libraries( IlmCtlMath Iex IlmThread Half )
else()
  target_link_libraries (IlmCtlMath
    #PRIVATE
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
endif()

set_target_properties( IlmCtlMath PROPERTIES
  VERSION ${CTL_VERSION}
  SOVERSION ${CTL_VERSION}
)

install( FILES
  CtlColorSpace.h
  CtlLookupTable.h
  CtlRbfInterpolator.h
  CtlSparseMatrix.h
 DESTINATION include/CTL )

install( TARGETS IlmCtlMath DESTINATION lib )

# TODO Add Imath and Iex libadd dependency and version info
