#!/bin/bash

set -x
#set -v
set -u 
#set -e

# input/output image directories
INPUT_IMAGE_DIR=/usr/src/aces-reference/images
OUTPUT_IMAGE_DIR=/tmp

# CTL ACES base path
CTLBASE=/usr/src/aces-dev/transforms/ctl

# set path to ACES CTL modules
export CTL_MODULE_PATH=$CTLBASE/csc/ADX/:$CTLBASE/idt/vendorSupplied/sony/:$CTLBASE/lib/:$CTLBASE/lmt/:$CTLBASE/odt/rec709/:$CTLBASE/rrt/:$CTLBASE/utilities/

# camera to ACES
ctlrender -force -compression NONE -ctl $CTLBASE/csc/ADX/ACEScsc.Academy.ADX10_to_ACES.ctl -global_param1 aIn 1.0 -format exr16 $INPUT_IMAGE_DIR/camera/DigitalLAD.2048x1556.dpx $OUTPUT_IMAGE_DIR/ACES_DigitalLAD.2048x1556.exr
ctlrender -force -compression NONE -ctl $CTLBASE/idt/vendorSupplied/sony/IDT.Sony.SLog1_SGamut_10i.ctl -global_param1 aIn 1.0 -format exr16 $INPUT_IMAGE_DIR/camera/SonyF35.StillLife.dpx $OUTPUT_IMAGE_DIR/ACES_SonyF35.StillLife.exr
ctlrender -force -compression NONE -ctl $CTLBASE/utilities/ACESutil.Unity.ctl -global_param1 aIn 1.0 -format exr16 $INPUT_IMAGE_DIR/camera/syntheticChart.01.exr $OUTPUT_IMAGE_DIR/ACES_syntheticChart.01.exr

# ACES to OCES
ctlrender -force -compression NONE -ctl $CTLBASE/rrt/RRT.ctl -format exr16 $INPUT_IMAGE_DIR/ACES/SonyF35.StillLife.exr $OUTPUT_IMAGE_DIR/OCES_SonyF35.StillLife.exr
ctlrender -force -compression NONE -ctl $CTLBASE/rrt/RRT.ctl -format exr16 $INPUT_IMAGE_DIR/ACES/syntheticChart.01.exr $OUTPUT_IMAGE_DIR/OCES_syntheticChart.01.exr

# OCES to Rec709
ctlrender -force -compression NONE -ctl $CTLBASE/odt/rec709/ODT.Academy.Rec709_100nits_dim.ctl -format tiff16 $INPUT_IMAGE_DIR/OCES/SonyF35.StillLife.exr $OUTPUT_IMAGE_DIR/ODT_SonyF35.StillLife_ODT.Academy.Rec709_100nits_dim.tiff
ctlrender -force -compression NONE -ctl $CTLBASE/odt/rec709/ODT.Academy.Rec709_100nits_dim.ctl -format tiff16 $INPUT_IMAGE_DIR/OCES/syntheticChart.01.exr $OUTPUT_IMAGE_DIR/ODT_syntheticChart.01_ODT.Academy.Rec709_100nits_dim.tiff

# concatenated ctl rendering
ctlrender -force -compression NONE -ctl $CTLBASE/idt/vendorSupplied/sony/IDT.Sony.SLog1_SGamut_10i.ctl -global_param1 aIn 1.0 -ctl $CTLBASE/rrt/RRT.ctl -ctl $CTLBASE/odt/rec709/ODT.Academy.Rec709_100nits_dim.ctl -format tiff16 $INPUT_IMAGE_DIR/camera/SonyF35.StillLife.dpx $OUTPUT_IMAGE_DIR/ACESOCESODT_SonyF35.StillLife_ODT.Academy.Rec709_100nits_dim.tiff 
ctlrender -force -compression NONE -global_param1 aIn 1.0 -ctl $CTLBASE/utilities/ACESutil.Unity.ctl -ctl $CTLBASE/rrt/RRT.ctl -ctl $CTLBASE/odt/rec709/ODT.Academy.Rec709_100nits_dim.ctl -format tiff16 $INPUT_IMAGE_DIR/camera/syntheticChart.01.exr $OUTPUT_IMAGE_DIR/ACESOCESODT_syntheticChart.01_ODT.Academy.Rec709_100nits_dim.tiff

# copy reference images to output directory to simplify debugging and comparison
cp $INPUT_IMAGE_DIR/ACES/DigitalLAD.2048x1556.exr $OUTPUT_IMAGE_DIR/ACESreference_ACES_DigitalLAD.2048x1556.exr
cp $INPUT_IMAGE_DIR/ACES/SonyF35.StillLife.exr $OUTPUT_IMAGE_DIR/ACESreference_SonyF35.StillLife.exr
cp $INPUT_IMAGE_DIR/ACES/syntheticChart.01.exr $OUTPUT_IMAGE_DIR/ACESreference_syntheticChart.01.exr
cp $INPUT_IMAGE_DIR/OCES/SonyF35.StillLife.exr $OUTPUT_IMAGE_DIR/OCESreference_SonyF35.StillLife.01.exr
cp $INPUT_IMAGE_DIR/OCES/syntheticChart.01.exr $OUTPUT_IMAGE_DIR/OCESreference_syntheticChart.01.exr
cp $INPUT_IMAGE_DIR/ODT/SonyF35.StillLife_ODT.Academy.Rec709_100nits_dim.tiff $OUTPUT_IMAGE_DIR/ODTreference_SonyF35.StillLife_ODT.Academy.Rec709_100nits_dim.tiff
cp $INPUT_IMAGE_DIR/ODT/syntheticChart.01_ODT.Academy.Rec709_100nits_dim.tiff $OUTPUT_IMAGE_DIR/ODTreference_syntheticChart.01_ODT.Academy.Rec709_100nits_dim.tiff

# compare images
METRIC_VALUE="PAE"
#DIFFERENCE_IMAGE_FILENAME="null:" # use null: to prevent creation of output difference image file
 
COMPUTED_IMAGE_FILENAME="${OUTPUT_IMAGE_DIR}/ACES_DigitalLAD.2048x1556.exr"
REFERENCE_IMAGE_FILENAME="${INPUT_IMAGE_DIR}/ACES/DigitalLAD.2048x1556.exr"
DIFFERENCE_IMAGE_FILENAME="${OUTPUT_IMAGE_DIR}/difference_image_ACES_DigitalLAD.2048x1556.exr"
compare -verbose -metric ${METRIC_VALUE} ${COMPUTED_IMAGE_FILENAME} ${REFERENCE_IMAGE_FILENAME} ${DIFFERENCE_IMAGE_FILENAME} 2>&1
test_01_exitcode=$? 
test_01_label="ACES_DigitalLAD.2048x1556.exr"

COMPUTED_IMAGE_FILENAME="${OUTPUT_IMAGE_DIR}/ACES_SonyF35.StillLife.exr"
REFERENCE_IMAGE_FILENAME="${INPUT_IMAGE_DIR}/ACES/SonyF35.StillLife.exr"
#DIFFERENCE_IMAGE_FILENAME="${OUTPUT_IMAGE_DIR}/difference_image_ACES_SonyF35.StillLife.exr"
DIFFERENCE_IMAGE_FILENAME="null:"
compare -verbose -metric ${METRIC_VALUE} ${COMPUTED_IMAGE_FILENAME} ${REFERENCE_IMAGE_FILENAME} ${DIFFERENCE_IMAGE_FILENAME} 2>&1
test_02_exitcode=$? 
test_02_label="ACES_SonyF35.StillLife.exr"

COMPUTED_IMAGE_FILENAME="${OUTPUT_IMAGE_DIR}/ACES_syntheticChart.01.exr"
REFERENCE_IMAGE_FILENAME="${INPUT_IMAGE_DIR}/ACES/syntheticChart.01.exr"
compare -verbose -metric $METRIC_VALUE ${COMPUTED_IMAGE_FILENAME} ${REFERENCE_IMAGE_FILENAME} ${DIFFERENCE_IMAGE_FILENAME} 2>&1
test_03_exitcode=$? 
test_03_label="ACES_syntheticChart.01.exr"

COMPUTED_IMAGE_FILENAME="${OUTPUT_IMAGE_DIR}/OCES_SonyF35.StillLife.exr"
REFERENCE_IMAGE_FILENAME="${INPUT_IMAGE_DIR}/OCES/SonyF35.StillLife.exr"
compare -verbose -metric $METRIC_VALUE ${COMPUTED_IMAGE_FILENAME} ${REFERENCE_IMAGE_FILENAME} ${DIFFERENCE_IMAGE_FILENAME} 2>&1
test_04_exitcode=$? 
test_04_label="OCES_SonyF35.StillLife.exr"

COMPUTED_IMAGE_FILENAME="${OUTPUT_IMAGE_DIR}/OCES_syntheticChart.01.exr"
REFERENCE_IMAGE_FILENAME="${INPUT_IMAGE_DIR}/OCES/syntheticChart.01.exr"
compare -verbose -metric $METRIC_VALUE ${COMPUTED_IMAGE_FILENAME} ${REFERENCE_IMAGE_FILENAME} ${DIFFERENCE_IMAGE_FILENAME} 2>&1
test_05_exitcode=$? 
test_05_label="OCES_syntheticChart.01.exr"

COMPUTED_IMAGE_FILENAME="${OUTPUT_IMAGE_DIR}/ODT_SonyF35.StillLife_ODT.Academy.Rec709_100nits_dim.tiff"
REFERENCE_IMAGE_FILENAME="${INPUT_IMAGE_DIR}/ODT/SonyF35.StillLife_ODT.Academy.Rec709_100nits_dim.tiff"
compare -verbose -metric $METRIC_VALUE ${COMPUTED_IMAGE_FILENAME} ${REFERENCE_IMAGE_FILENAME} ${DIFFERENCE_IMAGE_FILENAME} 2>&1
test_06_exitcode=$? 
test_06_label="ODT_SonyF35.StillLife_ODT.Academy.Rec709_100nits_dim.tiff"

COMPUTED_IMAGE_FILENAME="${OUTPUT_IMAGE_DIR}/ODT_syntheticChart.01_ODT.Academy.Rec709_100nits_dim.tiff"
REFERENCE_IMAGE_FILENAME="${INPUT_IMAGE_DIR}/ODT/syntheticChart.01_ODT.Academy.Rec709_100nits_dim.tiff"
compare -verbose -metric $METRIC_VALUE ${COMPUTED_IMAGE_FILENAME} ${REFERENCE_IMAGE_FILENAME} ${DIFFERENCE_IMAGE_FILENAME} 2>&1
test_07_exitcode=$? 
test_07_label="ODT_syntheticChart.01_ODT.Academy.Rec709_100nits_dim.tiff"

COMPUTED_IMAGE_FILENAME="${OUTPUT_IMAGE_DIR}/ACESOCESODT_SonyF35.StillLife_ODT.Academy.Rec709_100nits_dim.tiff"
REFERENCE_IMAGE_FILENAME="${INPUT_IMAGE_DIR}/ODT/SonyF35.StillLife_ODT.Academy.Rec709_100nits_dim.tiff"
compare -verbose -metric $METRIC_VALUE ${COMPUTED_IMAGE_FILENAME} ${REFERENCE_IMAGE_FILENAME} ${DIFFERENCE_IMAGE_FILENAME} 2>&1
test_08_exitcode=$? 
test_08_label="ACESOCESODT_SonyF35.StillLife_ODT.Academy.Rec709_100nits_dim.tiff"

COMPUTED_IMAGE_FILENAME="${OUTPUT_IMAGE_DIR}/ACESOCESODT_syntheticChart.01_ODT.Academy.Rec709_100nits_dim.tiff"
REFERENCE_IMAGE_FILENAME="${INPUT_IMAGE_DIR}/ODT/syntheticChart.01_ODT.Academy.Rec709_100nits_dim.tiff"
compare -verbose -metric $METRIC_VALUE ${COMPUTED_IMAGE_FILENAME} ${REFERENCE_IMAGE_FILENAME} ${DIFFERENCE_IMAGE_FILENAME} 2>&1
test_09_exitcode=$? 
test_09_label="ACESOCESODT_syntheticChart.01_ODT.Academy.Rec709_100nits_dim.tiff"

set +x
echo ""
echo "Test Summary:"

if [ $test_01_exitcode -eq 0 ] && [ $test_02_exitcode -eq 0 ] && [ $test_03_exitcode -eq 0 ] && [ $test_04_exitcode -eq 0 ] && [ $test_05_exitcode -eq 0 ] && [ $test_06_exitcode -eq 0 ] && [ $test_07_exitcode -eq 0 ] && [ $test_08_exitcode -eq 0 ] && [ $test_09_exitcode -eq 0 ] && [ $test_10_exitcode -eq 0 ]
then
    echo "SUCCESS: ACES ctlrender output matches ACES reference files exactly"
    exit 0
else
    echo "FAILURE: ACES ctlrender output does not match ACES reference files exactly"

    if [ $test_01_exitcode -ne 0 ]
    then 
        echo "$test_01_label: imagemagick compare detected differences" 
    else 
        echo "$test_01_label: imagemagick compare no detected differences" 
    fi

    if [ $test_02_exitcode -ne 0 ]
    then 
        echo "$test_02_label: imagemagick compare detected differences" 
    else 
        echo "$test_02_label: imagemagick compare no detected differences" 
    fi

    if [ $test_03_exitcode -ne 0 ]
    then 
        echo "$test_03_label: imagemagick compare detected differences" 
    else 
        echo "$test_03_label: imagemagick compare no detected differences" 
    fi

    if [ $test_04_exitcode -ne 0 ]
    then 
        echo "$test_04_label: imagemagick compare detected differences" 
    else 
        echo "$test_04_label: imagemagick compare no detected differences" 
    fi

    if [ $test_05_exitcode -ne 0 ]
    then 
        echo "$test_05_label: imagemagick compare detected differences" 
    else 
        echo "$test_05_label: imagemagick compare no detected differences" 
    fi

    if [ $test_06_exitcode -ne 0 ]
    then 
        echo "$test_06_label: imagemagick compare detected differences" 
    else 
        echo "$test_06_label: imagemagick compare no detected differences" 
    fi

    if [ $test_07_exitcode -ne 0 ]
    then 
        echo "$test_07_label: imagemagick compare detected differences" 
    else 
        echo "$test_07_label: imagemagick compare no detected differences" 
    fi

    if [ $test_08_exitcode -ne 0 ]
    then 
        echo "$test_08_label: imagemagick compare detected differences" 
    else 
        echo "$test_08_label: imagemagick compare no detected differences" 
    fi

    if [ $test_09_exitcode -ne 0 ]
    then 
        echo "$test_09_label: imagemagick compare detected differences" 
    else 
        echo "$test_09_label: imagemagick compare no detected differences" 
    fi

    exit 1

fi