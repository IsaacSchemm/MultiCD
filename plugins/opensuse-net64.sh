#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#openSUSE 64-bit installer plugin for multicd.sh
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
	echo "openSUSE-*-NET-x86_64.iso opensuse-net64.iso none"
elif [ $1 = scan ];then
	if [ -f opensuse-net64.iso ];then
		echo "openSUSE 64-bit netboot installer"
	fi
elif [ $1 = copy ];then
	if [ -f opensuse-net64.iso ];then
		echo "Copying openSUSE 64-bit netboot installer..."
		mcdmount opensuse-net64
		mkdir -p "${WORK}"/boot/opensuse
		awk '/^VERSION/ {print $2}' "${MNT}"/opensuse-net64/content > "${TAGS}"/opensuse-net.version
		cp "${MNT}"/opensuse-net64/boot/x86_64/loader/linux "${WORK}"/boot/opensuse/linux64
		cp "${MNT}"/opensuse-net64/boot/x86_64/loader/initrd "${WORK}"/boot/opensuse/initrd64
		umcdmount opensuse-net64
	fi
elif [ $1 = writecfg ];then
if [ -f opensuse-net64.iso ];then
echo "menu begin --> ^openSUSE netboot (x86_64)

label opensuse-kernel
  menu label Install ^openSUSE $(cat "${TAGS}"/opensuse-net.version) x86_64 (from mirrors.kernel.org)
  kernel /boot/opensuse/linux64
  append initrd=/boot/opensuse/initrd64 splash=silent showopts install=ftp://mirrors.kernel.org/opensuse/distribution/"$(cat "${TAGS}"/opensuse-net.version)"/repo/oss
label opensuse
  menu label Install openSUSE $(cat "${TAGS}"/opensuse-net.version) x86_64 (specify mirror)
  kernel /boot/opensuse/linux64
  append initrd=/boot/opensuse/initrd64 splash=silent showopts
label opensuse-repair
  menu label Repair an installed openSUSE x86_64 system
  kernel /boot/opensuse/linux64
  append initrd=/boot/opensuse/initrd64 splash=silent repair=1 showopts
label opensuse-rescue
  menu label openSUSE x86_64 rescue system
  kernel /boot/opensuse/linux64
  append initrd=/boot/opensuse/initrd64 splash=silent rescue=1 showopts
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
