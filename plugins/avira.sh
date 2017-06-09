#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Avira Rescue CD plugin for multicd.sh
#version 20150809
if [ $1 = links ];then
	echo "avira.iso avira.casper.iso Avira_Rescue_System"
	echo "rescue-system.iso avira.casper.iso Avira_Rescue_System"
fi
