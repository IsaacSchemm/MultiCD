#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#openSUSE installer plugin for multicd.sh
#version 6.9
#Copyright (c) 2010 Isaac Schemm
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
	echo "openSUSE-*-NET-i586.iso opensuse-net.iso none"
elif [ $1 = scan ];then
	if [ -f opensuse-net.iso ];then
		echo "openSUSE netboot installer"
	fi
elif [ $1 = copy ];then
	if [ -f opensuse-net.iso ];then
		echo "Copying openSUSE netboot installer..."
		mcdmount opensuse-net
		mkdir -p "${WORK}"/boot/opensuse
		awk '/^VERSION/ {print $2}' "${MNT}"/opensuse-net/content > "${TAGS}"/opensuse-net.version
		cp "${MNT}"/opensuse-net/boot/i386/loader/linux "${WORK}"/boot/opensuse/linux
		cp "${MNT}"/opensuse-net/boot/i386/loader/initrd "${WORK}"/boot/opensuse/initrd
		umcdmount opensuse-net
	fi
elif [ $1 = writecfg ];then
if [ -f opensuse-net.iso ];then
echo "menu begin --> ^openSUSE netboot

label opensuse-kernel
  menu label Install ^openSUSE $(cat "${TAGS}"/opensuse-net.version) (from mirrors.kernel.org)
  kernel /boot/opensuse/linux
  append initrd=/boot/opensuse/initrd splash=silent showopts install=ftp://mirrors.kernel.org/opensuse/distribution/"$(cat "${TAGS}"/opensuse-net.version)"/repo/oss
label opensuse
  menu label Install openSUSE $(cat "${TAGS}"/opensuse-net.version) (specify mirror)
  kernel /boot/opensuse/linux
  append initrd=/boot/opensuse/initrd splash=silent showopts
label opensuse-repair
  menu label Repair an installed openSUSE system
  kernel /boot/opensuse/linux
  append initrd=/boot/opensuse/initrd splash=silent repair=1 showopts
label opensuse-rescue
  menu label openSUSE rescue system
  kernel /boot/opensuse/linux
  append initrd=/boot/opensuse/initrd splash=silent rescue=1 showopts
label back
  menu label ^Back to main menu
  com32 menu.c32
  append isolinux.cfg

menu end
" >> "${WORK}"/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
