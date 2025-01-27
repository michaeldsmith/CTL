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

# copy reference images
cp $INPUT_IMAGE_DIR/ACES/DigitalLAD.2048x1556.exr $OUTPUT_IMAGE_DIR/ACESref_DigitalLAD.2048x1556.exr
cp $INPUT_IMAGE_DIR/ACES/SonyF35.StillLife.exr $OUTPUT_IMAGE_DIR/ACESref_SonyF35.StillLife.exr
cp $INPUT_IMAGE_DIR/ACES/syntheticChart.01.exr $OUTPUT_IMAGE_DIR/ACESref_syntheticChart.01.exr
cp $INPUT_IMAGE_DIR/OCES/SonyF35.StillLife.exr $OUTPUT_IMAGE_DIR/OCESref_SonyF35.StillLife.01.exr
cp $INPUT_IMAGE_DIR/OCES/syntheticChart.01.exr $OUTPUT_IMAGE_DIR/OCESref_syntheticChart.01.exr
cp $INPUT_IMAGE_DIR/ODT/SonyF35.StillLife_ODT.Academy.Rec709_100nits_dim.tiff $OUTPUT_IMAGE_DIR/ODTref_SonyF35.StillLife_ODT.Academy.Rec709_100nits_dim.tiff
cp $INPUT_IMAGE_DIR/ODT/syntheticChart.01_ODT.Academy.Rec709_100nits_dim.tiff $OUTPUT_IMAGE_DIR/ODTref_syntheticChart.01_ODT.Academy.Rec709_100nits_dim.tiff

# compare images
compare -verbose -metric PAE $OUTPUT_IMAGE_DIR/ACES_DigitalLAD.2048x1556.exr $INPUT_IMAGE_DIR/ACES/DigitalLAD.2048x1556.exr null: 2>&1
test_01_status=$? 
test_01_label="ACES_DigitalLAD.2048x1556.exr"
compare -verbose -metric PAE $OUTPUT_IMAGE_DIR/ACES_SonyF35.StillLife.exr $INPUT_IMAGE_DIR/ACES/SonyF35.StillLife.exr null: 2>&1
test_02_status=$? 
test_02_label="ACES_SonyF35.StillLife.exr"
compare -verbose -metric PAE $OUTPUT_IMAGE_DIR/ACES_syntheticChart.01.exr $INPUT_IMAGE_DIR/ACES/syntheticChart.01.exr null: 2>&1
test_03_status=$? 
test_03_label="ACES_syntheticChart.01.exr"

compare -verbose -metric PAE $OUTPUT_IMAGE_DIR/OCES_SonyF35.StillLife.exr $INPUT_IMAGE_DIR/OCES/SonyF35.StillLife.exr null: 2>&1
test_04_status=$? 
test_04_label="OCES_SonyF35.StillLife.exr"
compare -verbose -metric PAE $OUTPUT_IMAGE_DIR/OCES_syntheticChart.01.exr $INPUT_IMAGE_DIR/OCES/syntheticChart.01.exr null: 2>&1
test_05_status=$? 
test_05_label="OCES_syntheticChart.01.exr"

compare -verbose -metric PAE $OUTPUT_IMAGE_DIR/ODT_SonyF35.StillLife_ODT.Academy.Rec709_100nits_dim.tiff $INPUT_IMAGE_DIR/ODT/SonyF35.StillLife_ODT.Academy.Rec709_100nits_dim.tiff null: 2>&1
test_06_status=$? 
test_06_label="ODT_SonyF35.StillLife_ODT.Academy.Rec709_100nits_dim.tiff"
compare -verbose -metric PAE $OUTPUT_IMAGE_DIR/ODT_syntheticChart.01_ODT.Academy.Rec709_100nits_dim.tiff $INPUT_IMAGE_DIR/ODT/syntheticChart.01_ODT.Academy.Rec709_100nits_dim.tiff null: 2>&1
test_07_status=$? 
test_07_label="ODT_syntheticChart.01_ODT.Academy.Rec709_100nits_dim.tiff"

compare -verbose -metric PAE $OUTPUT_IMAGE_DIR/ACESOCESODT_SonyF35.StillLife_ODT.Academy.Rec709_100nits_dim.tiff $INPUT_IMAGE_DIR/ODT/SonyF35.StillLife_ODT.Academy.Rec709_100nits_dim.tiff null: 2>&1
test_08_status=$? 
test_08_label="ACESOCESODT_SonyF35.StillLife_ODT.Academy.Rec709_100nits_dim.tiff"
compare -verbose -metric PAE $OUTPUT_IMAGE_DIR/ACESOCESODT_syntheticChart.01_ODT.Academy.Rec709_100nits_dim.tiff $INPUT_IMAGE_DIR/ODT/syntheticChart.01_ODT.Academy.Rec709_100nits_dim.tiff null: 2>&1
test_09_status=$? 
test_09_label="ACESOCESODT_syntheticChart.01_ODT.Academy.Rec709_100nits_dim.tiff"

set +x

if [ $test_01_status -eq 0 ] && [ $test_02_status -eq 0 ] && [ $test_03_status -eq 0 ] && [ $test_04_status -eq 0 ] && [ $test_05_status -eq 0 ] && [ $test_06_status -eq 0 ] && [ $test_07_status -eq 0 ] && [ $test_08_status -eq 0 ] && [ $test_09_status -eq 0 ] && [ $test_10_status -eq 0 ]
then
    echo "Success: ACES ctlrender output matches ACES reference files exactly"
    exit 0
else
    echo "FAILURE: ACES ctlrender output does not match ACES reference files exactly"

    if [ $test_01_status -ne 0 ]
    then 
        echo "$test_01_label: imagemagick compare detected differences" 
    else 
        echo "$test_01_label: imagemagick compare no detected differences" 
    fi

    if [ $test_02_status -ne 0 ]
    then 
        echo "$test_02_label: imagemagick compare detected differences" 
    else 
        echo "$test_02_label: imagemagick compare no detected differences" 
    fi

    if [ $test_03_status -ne 0 ]
    then 
        echo "$test_03_label: imagemagick compare detected differences" 
    else 
        echo "$test_03_label: imagemagick compare no detected differences" 
    fi

    if [ $test_04_status -ne 0 ]
    then 
        echo "$test_04_label: imagemagick compare detected differences" 
    else 
        echo "$test_04_label: imagemagick compare no detected differences" 
    fi

    if [ $test_05_status -ne 0 ]
    then 
        echo "$test_05_label: imagemagick compare detected differences" 
    else 
        echo "$test_05_label: imagemagick compare no detected differences" 
    fi

    if [ $test_06_status -ne 0 ]
    then 
        echo "$test_06_label: imagemagick compare detected differences" 
    else 
        echo "$test_06_label: imagemagick compare no detected differences" 
    fi

    if [ $test_07_status -ne 0 ]
    then 
        echo "$test_07_label: imagemagick compare detected differences" 
    else 
        echo "$test_07_label: imagemagick compare no detected differences" 
    fi

    if [ $test_08_status -ne 0 ]
    then 
        echo "$test_08_label: imagemagick compare detected differences" 
    else 
        echo "$test_08_label: imagemagick compare no detected differences" 
    fi

    if [ $test_09_status -ne 0 ]
    then 
        echo "$test_09_label: imagemagick compare detected differences" 
    else 
        echo "$test_09_label: imagemagick compare no detected differences" 
    fi

    exit 1

fi