#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Custom file copy plugin for multicd.sh
#version 20150606
if [ $1 = scan ];then
	if [ -d "${MCDDIR}/backup" ];then
        echo "Adding files from backup folder"
        ls -l "backup"
	fi
elif [ $1 = copy ];then
	if [ -d "${MCDDIR}/backup" ];then
		echo "Copying custom backup folder to ISO..."
		cp -afrvu "${MCDDIR}/backup" "${WORK}"/
	fi
elif [ $1 = writecfg ];then
	true
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
