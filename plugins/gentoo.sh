#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Gentoo live CD plugin for multicd.sh
#version 20140410
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

gentooExists () {
	if [ "*.gentoo.iso" != "$(echo *.gentoo.iso)" ];then
		echo true
	else
		echo false
	fi
}

getGentooName () {
	BASENAME=$(echo $i|sed -e 's/\.iso//g')
	#get version
	if [ -f $BASENAME.version ] && [ "$(cat $BASENAME.version)" != "" ];then
		VERSION=" $(cat $BASENAME.version)" #Version based on isoaliases()
	else
		VERSION=""
	fi
	#get name
	if [ -f "${TAGS}"/$BASENAME.name ] && [ "$(cat "${TAGS}"/$BASENAME.name)" != "" ];then
		UBUNAME=$(cat "${TAGS}"/$BASENAME.name)
	elif [ -f $BASENAME.defaultname ] && [ "$(cat $BASENAME.defaultname)" != "" ];then
		UBUNAME="$(cat $BASENAME.defaultname)"
	else
		UBUNAME="$(echo $BASENAME|sed -e 's/\.gentoo//g') ${VERSION}"
	fi
	#return
	echo ${UBUNAME}
}

gentoocommon () {
	if [ ! -z "$1" ] && [ -f $1.iso ];then
		mcdmount $1
		mkdir "${WORK}"/boot/$1
		mcdcp "${MNT}"/$1/image.squashfs "${WORK}"/boot/$1/
		cp -r "${MNT}"/$1/boot/* "${WORK}"/boot/$1/
		cp "${MNT}"/$1/isolinux/*.cfg "${WORK}"/boot/$1/
		cp "${MNT}"/$1/isolinux/*.msg "${WORK}"/boot/$1/
		cp "${MNT}"/$1/isolinux/*.png "${WORK}"/boot/$1/
		rm "${WORK}"/boot/$1/memdisk || true
		touch "${WORK}"/livecd
		umcdmount $1

		cat "${WORK}"/boot/$1/isolinux.cfg |
			sed -e "s,/boot/,/boot/$1/,g" -e 's,/boot/$1/memdisk,/boot/isolinux/memdisk,g' -e "s, cdroot, cdroot loop=/boot/$1/image.squashfs,g" |
			perl -pe "s, ([^ ]*?)\.msg, /boot/${1}/\$1\.msg,g" |
			perl -pe "s, ([^ ]*?)\.png, /boot/${1}/\$1\.png,g" > /tmp/isolinux-$1.cfg
		cat /tmp/isolinux-$1.cfg > "${WORK}"/boot/$1/isolinux.cfg
		rm /tmp/isolinux-$1.cfg
	else
		echo "$0: \"$1\" is empty or not an ISO"
		exit 1
	fi
}

if [ $1 = links ];then
	echo "livedvd-amd64-multilib-*.iso gentoo64.gentoo.iso Gentoo_*_LiveDVD_(amd64)"
	echo "livedvd-x86-amd64-32ul-*.iso gentoo32.gentoo.iso Gentoo_*_LiveDVD_(x86)"
elif [ $1 = scan ];then
	if $(gentooExists);then
		for i in *.gentoo.iso; do
			getGentooName
			echo > "${TAGS}"/$(echo $i|sed -e 's/\.iso/\.needsname/g') #Comment out this line and multicd.sh won't ask for a custom name for this ISO
		done
	fi
elif [ $1 = copy ];then
	if $(gentooExists);then
		for i in *.gentoo.iso; do
			echo "Copying $(getGentooName)..."
			gentoocommon $(echo $i|sed -e 's/\.iso//g')
		done
	fi
elif [ $1 = writecfg ];then
	if $(gentooExists);then
		for i in *.gentoo.iso; do
			BASENAME=$(echo $i|sed -e 's/\.iso//g')
			UBUNAME=$(getGentooName)

			echo "label gentoo
menu label ^${UBUNAME}
com32 vesamenu.c32
append /boot/$BASENAME/isolinux.cfg" >> "${WORK}"/boot/isolinux/isolinux.cfg
		done
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
