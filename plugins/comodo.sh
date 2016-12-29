#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Comodo Rescue Disk for multicd.sh
#version 20161228
if [ $1 = links ];then
	echo "comodo_rescue_disk_*.iso comodo.generic.iso Comodo_Rescue_Disk_(*)"
fi
