
add_executable(IlmCtlMathTest 
    main.cpp
    testAffineRec.cpp
    testGaussRec.cpp
)

include_directories( "${CMAKE_CURRENT_SOURCE_DIR}" 
                     "${PROJECT_SOURCE_DIR}/lib/IlmCtlMath" )
                     
target_link_libraries( IlmCtlMathTest IlmCtlMath )
if ( NOT OpenEXR_FOUND )
  target_link_libraries( IlmCtlMathTest ${IlmBase_LIBRARIES} ${IlmBase_LDFLAGS_OTHER} )
else()
  target_link_libraries( IlmCtlMathTest 
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

add_test( IlmCtlMath IlmCtlMathTest )
add_dependencies(check IlmCtlMathTest)





#LDADD =	@ILMBASE_LIBS@ -L$(top_builddir)/IlmCtlMath \
#	-lIlmCtlMath -lImath -lIex -lHalf -lpthread -lm


