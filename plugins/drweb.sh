#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Dr.Web LiveCD plugin for multicd.sh
#version 20161227
if [ $1 = links ];then
	echo "drweb.iso drweb.casper.iso Dr.Web_LiveDisk"
	echo "drweb-livedisk-*.iso drweb.casper.iso Dr.Web_LiveDisk"
fi
