#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Ubuntu alternate install CD plugin for multicd.sh
#version 20121113
#Copyright (c) 2012 Isaac Schemm
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
if [ $1 = links ];then
	#Only one will be included, because only one can be used.
	echo "ubuntu-*-alternate-i386.iso ubuntu-alternate.iso Ubuntu_alternate_installer_(32-bit)"
	echo "ubuntu-*-alternate-amd64.iso ubuntu-alternate.iso Ubuntu_alternate_installer_(64-bit)"
	echo "kubuntu-*-alternate-i386.iso ubuntu-alternate.iso Kubuntu_alternate_installer_(32-bit)"
	echo "kubuntu-*-alternate-amd64.iso ubuntu-alternate.iso Kubuntu_alternate_installer_(64-bit)"
	echo "xubuntu-*-alternate-i386.iso ubuntu-alternate.iso Xubuntu_alternate_installer_(32-bit)"
	echo "xubuntu-*-alternate-amd64.iso ubuntu-alternate.iso Xubuntu_alternate_installer_(64-bit)"
	echo "lubuntu-*-alternate-i386.iso ubuntu-alternate.iso Lubuntu_alternate_installer_(32-bit)"
	echo "lubuntu-*-alternate-amd64.iso ubuntu-alternate.iso Lubuntu_alternate_installer_(64-bit)"
	echo "ubuntu-*-server-i386.iso ubuntu-alternate.iso Ubuntu_server_(32-bit)"
	echo "ubuntu-*-server-amd64.iso ubuntu-alternate.iso Ubuntu_server_(64-bit)"
elif [ $1 = scan ];then
	if [ -f ubuntu-alternate.iso ];then
		echo "Ubuntu alternate installer"
	fi
elif [ $1 = copy ];then
	if [ -f ubuntu-alternate.iso ];then
		if [ -d "${WORK}"/pool ];then
			echo "NOT copying Ubuntu alternate installer - some sort of Ubuntu/Debian installer is already present."
			touch "${TAGS}"/ubuntu-not-copied
		else
			echo "Copying Ubuntu alternate installer..."
			mcdmount ubuntu-alternate
			cp "${MNT}"/ubuntu-alternate/cdromupgrade "${WORK}" 2>&1 || true #Not essential
			cp -r "${MNT}"/ubuntu-alternate/.disk "${WORK}"
			cp -r "${MNT}"/ubuntu-alternate/dists "${WORK}"
			cp -r "${MNT}"/ubuntu-alternate/doc "${WORK}" || true
			cp -r "${MNT}"/ubuntu-alternate/install "${WORK}"
			cp -r "${MNT}"/ubuntu-alternate/pool "${WORK}"
			cp -r "${MNT}"/ubuntu-alternate/preseed "${WORK}"
			cp -r "${MNT}"/ubuntu-alternate/README.diskdefines "${WORK}"
			#cp -r "${MNT}"/ubuntu-alternate/ubuntu "${WORK}"
			if [ ! -e "${MNT}"/ubuntu-alternate/ubuntu ];then
				ln -s . "${MNT}"/ubuntu-alternate/ubuntu
			fi
			umcdmount ubuntu-alternate
		fi
	fi
elif [ $1 = writecfg ];then
if [ -f ubuntu-alternate.iso ] && [ ! -f "${TAGS}"/ubuntu-not-copied ];then
cd "$WORK"
PRESEED=$(echo preseed/*ubuntu*|awk '{print $1}')
cd -
if [ -f "${WORK}"/README.diskdefines ];then
	CDNAME="$(grep DISKNAME "${WORK}"/README.diskdefines|awk '{for (i=3; i<NF+1; i++) { printf $i; printf " " } printf "\n" }')"
else
	CDNAME="Ubuntu alternate installer"
fi
echo "menu begin --> ^$CDNAME

label install
  menu label ^Install Ubuntu
  kernel /install/vmlinuz
  append  file=/cdrom/$PRESEED vga=788 initrd=/install/initrd.gz quiet --

label expert
  menu label ^Expert install
  kernel /install/vmlinuz
  append  file=/cdrom/$PRESEED priority=low vga=788 initrd=/install/initrd.gz --
label rescue
  menu label ^Rescue a broken system
  kernel /install/vmlinuz
  append  rescue/enable=true vga=788 initrd=/install/initrd.gz --

menu end" >> "${WORK}"/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
