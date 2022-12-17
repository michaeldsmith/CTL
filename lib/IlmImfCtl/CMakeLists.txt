include_directories( "${CMAKE_CURRENT_SOURCE_DIR}" "${PROJECT_SOURCE_DIR}/lib/IlmCtl" "${PROJECT_SOURCE_DIR}/lib/IlmCtlMath" "${PROJECT_SOURCE_DIR}/lib/IlmCtlSimd" )
include_directories( ${OpenEXR_INCLUDE_DIRS} )
link_directories( ${OpenEXR_LIBRARY_DIRS} )

add_library( IlmImfCtl ${DO_SHARED}
  ImfCtlApplyTransforms.cpp
  ImfCtlCopyFunctionArg.cpp
)

#target_link_libraries( IlmImfCtl IlmCtl IlmImf Iex IlmThread Half )
target_link_libraries( IlmImfCtl 
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

install( FILES ImfCtlApplyTransforms.h DESTINATION include/OpenEXR )

export( TARGETS IlmImfCtl IlmCtl FILE "${PROJECT_BINARY_DIR}/CTLLibraryDepends.cmake" )

install( TARGETS IlmImfCtl DESTINATION lib )
