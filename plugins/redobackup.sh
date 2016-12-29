#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Redo Backup plugin for multicd.sh
#version 20161229
if [ $1 = links ];then
	echo "redobackup-livecd-*.iso redobackup.ubuntu.iso Redo_Backup_(*)"
fi
