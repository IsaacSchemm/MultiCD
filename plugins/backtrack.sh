#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#BackTrack plugin for multicd.sh (designed for BackTrack 4)
#version 20161229
if [ $1 = links ];then
	echo "BT5-*.iso backtrack.ubuntu.iso BackTrack"
fi
