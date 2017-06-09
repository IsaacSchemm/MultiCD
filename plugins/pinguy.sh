#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Pinguy OS plugin for multicd.sh
#version 20150809
if [ $1 = links ];then
	echo "Pinguy_OS_*.iso pinguy.casper.iso none"
fi
