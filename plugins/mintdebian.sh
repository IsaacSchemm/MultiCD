#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Linux Mint Debian Edition plugin for multicd.sh
#version 20150809
if [ $1 = links ];then
	echo "linuxmint-debian-*.iso mintdebian.ubuntu.iso Linux_Mint_Debian_Edition"
	echo "lmde-*.iso mintdebian.ubuntu.iso Linux_Mint_Debian_Edition"
fi
