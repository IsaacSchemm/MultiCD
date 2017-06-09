#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Boot-Repair-Disk plugin for multicd.sh
#version 20161011
if [ $1 = links ];then
	echo "boot-repair-disk*.iso boot-repair-disk.casper.iso Boot-Repair-Disk_*"
fi
