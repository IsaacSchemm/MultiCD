#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Zorin OS plugin for multicd.sh
#version 20221119
if [ $1 = links ];then
	echo "zorin-os-*.iso zorin.casper.iso Zorin_OS"
	echo "Zorin-OS-*.iso zorin.casper.iso Zorin_OS"
fi
