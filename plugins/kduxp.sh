#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#KDuXP plugin for multicd.sh
#version 20161229
if [ $1 = links ];then
	echo "KDuXPv*.iso kduxp.casper.iso KDuXP"
fi
