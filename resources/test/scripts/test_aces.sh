#!/bin/bash

set -x
set -u 
#set -e

# input/output image directories
INPUT_IMAGE_DIR=/usr/src/aces-dev/images
OUTPUT_IMAGE_DIR=/tmp

# CTL ACES base path
CTLBASE=/usr/src/aces-dev/transforms/ctl

# set path to ACES CTL modules
export CTL_MODULE_PATH=$CTLBASE/csc/ADX/:$CTLBASE/idt/vendorSupplied/sony/:$CTLBASE/lib/:$CTLBASE/lmt/:$CTLBASE/odt/rec709/:$CTLBASE/rrt/:$CTLBASE/utilities/

# camera to ACES
ctlrender -force -compression NONE -ctl $CTLBASE/csc/ADX/ACEScsc.Academy.ADX10_to_ACES.ctl -global_param1 aIn 1.0 -format exr16 $INPUT_IMAGE_DIR/camera/DigitalLAD.2048x1556.dpx $OUTPUT_IMAGE_DIR/ACES_DigitalLAD.2048x1556.exr
ctlrender -force -compression NONE -ctl $CTLBASE/idt/vendorSupplied/sony/IDT.Sony.SLog1_SGamut_10i.ctl -global_param1 aIn 1.0 -format exr16 $INPUT_IMAGE_DIR/camera/SonyF35.StillLife.dpx $OUTPUT_IMAGE_DIR/ACES_SonyF35.StillLife.exr
ctlrender -force -compression NONE -ctl $CTLBASE/utilities/ACESutil.Unity.ctl $INPUT_IMAGE_DIR/camera/syntheticChart.01.exr $OUTPUT_IMAGE_DIR/ACES_syntheticChart.01.exr

# ACES to OCES
ctlrender -force -compression NONE -ctl $CTLBASE/rrt/RRT.ctl -format exr16 $INPUT_IMAGE_DIR/ACES/SonyF35.StillLife.exr $OUTPUT_IMAGE_DIR/OCES_SonyF35.StillLife.exr
ctlrender -force -compression NONE -ctl $CTLBASE/rrt/RRT.ctl -format exr16 $INPUT_IMAGE_DIR/ACES/syntheticChart.01.exr $OUTPUT_IMAGE_DIR/OCES_syntheticChart.01.exr

# OCES to Rec709
ctlrender -force -compression NONE -ctl $CTLBASE/odt/rec709/ODT.Academy.Rec709_100nits_dim.ctl -format tiff16 $INPUT_IMAGE_DIR/OCES/SonyF35.StillLife.exr $OUTPUT_IMAGE_DIR/ODT_SonyF35.StillLife_ODT.Academy.Rec709_100nits_dim.tiff
ctlrender -force -compression NONE -ctl $CTLBASE/odt/rec709/ODT.Academy.Rec709_100nits_dim.ctl -format tiff16 $INPUT_IMAGE_DIR/OCES/syntheticChart.01.exr $OUTPUT_IMAGE_DIR/ODT_syntheticChart.01_ODT.Academy.Rec709_100nits_dim.tiff

# concatenated ctl rendering
ctlrender -force -compression NONE -ctl $CTLBASE/idt/vendorSupplied/sony/IDT.Sony.SLog1_SGamut_10i.ctl -global_param1 aIn 1.0 -ctl $CTLBASE/rrt/RRT.ctl -ctl $CTLBASE/odt/rec709/ODT.Academy.Rec709_100nits_dim.ctl -format tiff16 $INPUT_IMAGE_DIR/camera/SonyF35.StillLife.dpx $OUTPUT_IMAGE_DIR/ACESOCESODT_SonyF35.StillLife_ODT.Academy.Rec709_100nits_dim.tiff 
ctlrender -force -compression NONE -ctl $CTLBASE/utilities/ACESutil.Unity.ctl -ctl $CTLBASE/rrt/RRT.ctl -ctl $CTLBASE/odt/rec709/ODT.Academy.Rec709_100nits_dim.ctl -format tiff16 $INPUT_IMAGE_DIR/camera/syntheticChart.01.exr $OUTPUT_IMAGE_DIR/ACESOCESODT_syntheticChart.01_ODT.Academy.Rec709_100nits_dim.tiff

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
compare -verbose -metric PAE $OUTPUT_IMAGE_DIR/ACES_SonyF35.StillLife.exr $INPUT_IMAGE_DIR/ACES/SonyF35.StillLife.exr null: 2>&1
compare -verbose -metric PAE $OUTPUT_IMAGE_DIR/ACES_syntheticChart.01.exr $INPUT_IMAGE_DIR/ACES/syntheticChart.01.exr null: 2>&1

compare -verbose -metric PAE $OUTPUT_IMAGE_DIR/OCES_SonyF35.StillLife.exr $INPUT_IMAGE_DIR/OCES/SonyF35.StillLife.exr null: 2>&1
compare -verbose -metric PAE $OUTPUT_IMAGE_DIR/OCES_syntheticChart.01.exr $INPUT_IMAGE_DIR/OCES/syntheticChart.01.exr null: 2>&1

compare -verbose -metric PAE $OUTPUT_IMAGE_DIR/ODT_SonyF35.StillLife_ODT.Academy.Rec709_100nits_dim.tiff $INPUT_IMAGE_DIR/ODT/SonyF35.StillLife_ODT.Academy.Rec709_100nits_dim.tiff null: 2>&1
compare -verbose -metric PAE $OUTPUT_IMAGE_DIR/ODT_syntheticChart.01_ODT.Academy.Rec709_100nits_dim.tiff $INPUT_IMAGE_DIR/ODT/syntheticChart.01_ODT.Academy.Rec709_100nits_dim.tiff null: 2>&1

compare -verbose -metric PAE $OUTPUT_IMAGE_DIR/ACESOCESODT_SonyF35.StillLife_ODT.Academy.Rec709_100nits_dim.tiff $INPUT_IMAGE_DIR/ODT/SonyF35.StillLife_ODT.Academy.Rec709_100nits_dim.tiff null: 2>&1
compare -verbose -metric PAE $OUTPUT_IMAGE_DIR/ACESOCESODT_syntheticChart.01_ODT.Academy.Rec709_100nits_dim.tiff $INPUT_IMAGE_DIR/ODT/syntheticChart.01_ODT.Academy.Rec709_100nits_dim.tiff null: 2>&1