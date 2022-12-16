include_directories( "${CMAKE_CURRENT_SOURCE_DIR}" )

add_library( IlmCtl ${DO_SHARED}
 CtlAddr.cpp
 CtlAlign.cpp
 CtlExc.cpp
 CtlFunctionCall.cpp
 CtlInterpreter.cpp
 CtlLContext.cpp
 CtlLex.cpp
 CtlMessage.cpp
 CtlModule.cpp
 CtlModuleSet.cpp
 CtlParser.cpp
 CtlRcPtr.cpp
 CtlSymbolTable.cpp
 CtlSyntaxTree.cpp
 CtlTokens.cpp
 CtlType.cpp
 CtlTypeStorage.cpp
 CtlStdType.cpp
)

if ( NOT OpenEXR_FOUND )
	target_link_libraries( IlmCtl ${IlmBase_LDFLAGS_OTHER} )
endif()
#target_link_libraries( IlmCtl Iex IlmThread Half )
target_link_libraries (IlmCtl
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

set_target_properties( IlmCtl PROPERTIES
  VERSION ${CTL_VERSION}
  SOVERSION ${CTL_VERSION}
)

install( FILES
	CtlAddr.h
	CtlAlign.h
	CtlErrors.h
	CtlExc.h
	CtlFunctionCall.h
	CtlInterpreter.h
	CtlLContext.h
	CtlMessage.h
	CtlModule.h
	CtlRcPtr.h
	CtlReadWriteAccess.h
	CtlSymbolTable.h
	CtlSyntaxTree.h
	CtlTokens.h
	CtlType.h
	CtlTypeStorage.h
	CtlStdType.h
	CtlVersion.h
 DESTINATION include/CTL )

install( TARGETS IlmCtl DESTINATION lib )
