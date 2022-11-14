if ( NOT TIFF_FOUND )
    message(WARNING "LibTIFF not found, skipping tiff-related ctlrender unit tests")
    add_test(
        NAME ctlrender-dpx
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMAND ./test_dpx.sh $<TARGET_FILE:ctlrender>
    )
else()
    add_test(
        NAME ctlrender
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMAND ./test.sh $<TARGET_FILE:ctlrender>
    )
endif()

#add_dependencies(check ctlrender)
