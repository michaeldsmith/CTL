#! /bin/bash
CTLRENDER=$1

mkdir output

for J in dpx8 dpx10 dpx12 dpx16; do
	for I in bars_cinepaint_10.dpx bars_nuke_10_be.dpx bars_nuke_10_le.dpx bars_nuke_12_be.dpx bars_nuke_12_le.dpx bars_nuke_16_be.dpx bars_nuke_16_le.dpx bars_nuke_8_be.dpx bars_nuke_8_le.dpx ; do
		name=`echo $I | sed -e 's/\..*//'`
		ext=`echo $J | sed -e 's/[0-9]//g'`
		echo ${I} '->' ${J}
		$CTLRENDER -ctl unity.ctl -format ${J} -force ${I} output/${name}_${J}.${ext}
	done
	echo ${J} unity test
done
