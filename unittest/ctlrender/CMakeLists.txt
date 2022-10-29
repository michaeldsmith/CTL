
if ( OpenEXR_FOUND )
add_definitions( -DHAVE_OPENEXR=1 )
endif()

add_test(
    NAME ctlrender
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMAND ./test.sh $<TARGET_FILE:ctlrender>
)

#add_dependencies(check ctlrender)
