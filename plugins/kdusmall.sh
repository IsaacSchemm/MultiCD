#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#KDu-Small plugin for multicd.sh
#version 20161229
if [ $1 = links ];then
	echo "KDu-Small-*.iso kdusmall.ubuntu.iso KDu-Small"
fi
