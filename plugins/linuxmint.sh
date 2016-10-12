#!/bin/bash
set -e
. "${MCDDIR}"/functions.sh
#Linux Mint and LMDE plugin for multicd.sh
#version 20161012
if [ $1 = links ];then
	echo "linuxmint-*.iso linuxmint.ubuntu.iso Linux_Mint_*"
	echo "linuxmint-debian-*.iso linuxmint.debian.iso Linux_Mint_Debian_Edition_*"
	echo "lmde-*.iso linuxmint.debian.iso Linux_Mint_Debian_Edition_*"
fi
