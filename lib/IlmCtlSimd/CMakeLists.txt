include_directories( "${CMAKE_CURRENT_SOURCE_DIR}" "${PROJECT_SOURCE_DIR}/lib/IlmCtl" "${PROJECT_SOURCE_DIR}/lib/IlmCtlMath" )

add_executable( halfExpLogTable halfExpLogTable.cpp )
#target_link_libraries( halfExpLogTable Half )
target_link_libraries (halfExpLogTable
    PRIVATE
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

add_custom_command( OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/halfExpLogTable.h"
                    COMMAND halfExpLogTable "${CMAKE_CURRENT_BINARY_DIR}/halfExpLogTable.h" "${CMAKE_CURRENT_BINARY_DIR}/halfExpLog.h"
                    DEPENDS halfExpLogTable )

include_directories( "${CMAKE_CURRENT_BINARY_DIR}" )

add_library( IlmCtlSimd ${DO_SHARED}
	CtlSimdAddr.cpp
	CtlSimdFunctionCall.cpp
	CtlSimdHalfExpLog.cpp
	CtlSimdInst.cpp
	CtlSimdInterpreter.cpp
	CtlSimdLContext.cpp
	CtlSimdModule.cpp
	CtlSimdReg.cpp
	CtlSimdStdLibAssert.cpp
	CtlSimdStdLibColorSpace.cpp
	CtlSimdStdLibInterpolator.cpp
	CtlSimdStdLibLimits.cpp
	CtlSimdStdLibLookupTable.cpp
	CtlSimdStdLibMath.cpp
	CtlSimdStdLibPrint.cpp
	CtlSimdStdLibrary.cpp
	CtlSimdStdTypes.cpp
	CtlSimdSyntaxTree.cpp
	CtlSimdType.cpp
	CtlSimdXContext.cpp
	"${CMAKE_CURRENT_BINARY_DIR}/halfExpLogTable.h"
)

target_link_libraries( IlmCtlSimd IlmCtlMath IlmCtl )
target_link_libraries( IlmCtlSimd
    PRIVATE
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

set_target_properties( IlmCtlSimd PROPERTIES
  VERSION ${CTL_VERSION}
  SOVERSION ${CTL_VERSION}
)

install( FILES CtlSimdInterpreter.h DESTINATION include/CTL )

install( TARGETS IlmCtlSimd DESTINATION lib )
