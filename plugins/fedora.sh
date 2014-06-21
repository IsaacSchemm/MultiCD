#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Fedora LiveOS plugin for multicd.sh
#version 20140621
#Copyright (c) 2014 Isaac Schemm
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

#START FUNCTIONS#
fedoraExists () {
	if [ "*.fedora.iso" != "$(echo *.fedora.iso)" ];then
		echo true
	else
		echo false
	fi
}

getFedoraName () {
	BASENAME=$(echo $i|sed -e 's/\.iso//g')
	if [ -f "${TAGS}"/$BASENAME.name ] && [ "$(cat "${TAGS}"/$BASENAME.name)" != "" ];then
		ISONAME=$(cat "${TAGS}"/$BASENAME.name) # either entered interactively, or copied from .defaultname
		echo $ISONAME >&2
		# (.name files are copied to .defaultname and will make their way to this file as well)
	elif [ -f $BASENAME.defaultname ] && [ "$(cat $BASENAME.defaultname)" != "" ];then
		# .name files are not written until after the "wait 2 seconds or press ctrl+c" message
		ISONAME="$(cat $BASENAME.defaultname)"
	else
		# Can occur if you make the *.fedora.iso link yourself
		ISONAME="$(echo $BASENAME|sed -e 's/\.fedora//g')"
		if [ -f $BASENAME.version ];then
			ISONAME="$ISONAME $(cat $BASENAME.version)" #Version based on isoaliases()
		fi
	fi
	echo ${ISONAME}
}

fedoracommon () {
	if [ ! -z "$1" ] && [ -f $1.iso ];then
		mcdmount $1
		mcdcp -r "${MNT}"/$1/LiveOS "${WORK}"/boot/$1
		cp "${MNT}"/$1/isolinux/vmlinuz* "${WORK}"/boot/$1
		cp "${MNT}"/$1/isolinux/init* "${WORK}"/boot/$1
		cp "${MNT}"/$1/isolinux/*.png "${WORK}"/boot/$1 2> /dev/null || true
		< "${MNT}"/$1/isolinux/isolinux.cfg sed '/^label memtest/,$d' > "${WORK}"/boot/$1/isolinux.cfg
		echo "label back
		menu label Back to main menu
		com32 menu.c32
		append /boot/isolinux/isolinux.cfg
		" >> "${WORK}"/boot/$1/isolinux.cfg
		sed -i "s,kernel vmlinuz,kernel /boot/$1/vmlinuz,g" "${WORK}"/boot/$1/isolinux.cfg
		sed -i "s,^menu background ,menu background /boot/$1/,g" "${WORK}"/boot/$1/isolinux.cfg
		sed -i "s,initrd=,rd.live.dir=/boot/$1 initrd=/boot/$1/,g" "${WORK}"/boot/$1/isolinux.cfg
		sed -i "s,CDLABEL=[^ ]* ,CDLABEL=$CDLABEL ,g" "${WORK}"/boot/$1/isolinux.cfg
		#if [ -f "${TAGS}"/lang ];then
		#	echo added lang
		#	sed -i "s^initrd=/boot/$1/^debian-installer/language=$(cat "${TAGS}"/lang) initrd=/boot/$1/^g" "${WORK}"/boot/$1/$1.cfg #Add language codes to cmdline
		#fi
		#if [ -f "${TAGS}"/country ];then
		#	echo added country
		#	sed -i "s^initrd=/boot/$1/^console-setup/layoutcode?=$(cat "${TAGS}"/country) initrd=/boot/$1/^g" "${WORK}"/boot/$1/$1.cfg #Add language codes to cmdline
		#fi
		umcdmount $1
	else
		echo "$0: \"$1\" is empty or not an ISO"
		exit 1
	fi
}
#END FUNCTIONS#

if [ $1 = links ];then
	echo "Fedora-Live-*-1.iso live.fedora.iso Fedora_(*)"
elif [ $1 = scan ];then
	if $(fedoraExists);then
		for i in *.fedora.iso; do
			getFedoraName
			echo > "${TAGS}"/$(echo $i|sed -e 's/\.iso/\.needsname/g') #Comment out this line and multicd.sh won't ask for a custom name or copy the .defaultname file into the tags folder
		done
	fi
elif [ $1 = copy ];then
	if $(fedoraExists);then
		for i in *.fedora.iso; do
			echo "Copying $(getFedoraName)..."
			fedoracommon $(echo $i|sed -e 's/\.iso//g')
		done
	fi
elif [ $1 = writecfg ];then
	if $(fedoraExists);then
		for i in *.fedora.iso; do
			BASENAME=$(echo $i|sed -e 's/\.iso//g')
			ISONAME=$(getFedoraName)

			echo "label $BASENAME
			menu label --> $ISONAME Menu
			com32 vesamenu.c32
			append /boot/$BASENAME/isolinux.cfg
			" >> "${WORK}"/boot/isolinux/isolinux.cfg
		done
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
