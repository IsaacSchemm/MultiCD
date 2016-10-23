#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Zorin OS plugin for multicd.sh
#version 20161022
if [ $1 = links ];then
	echo "zorin-os-*.iso zorin.ubuntu.iso Zorin_OS"
fi
