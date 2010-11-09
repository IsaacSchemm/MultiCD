#!/bin/sh
set -e
#openSUSE installer plugin for multicd.sh
#version 5.0
#Copyright (c) 2009 libertyernie
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
if [ $1 = scan ];then
	if [ -f opensuse.iso ];then
		echo "openSUSE netboot installer"
	fi
elif [ $1 = copy ];then
	if [ -f opensuse.iso ];then
		echo "Copying openSUSE netboot installer..."
		if [ ! -d opensuse ];then
			mkdir opensuse
		fi
		if grep -q "`pwd`/opensuse" /etc/mtab ; then
			umount opensuse
		fi
		mount -o loop opensuse.iso opensuse/
		mkdir multicd-working/boot/opensuse
		awk '/^VERSION/ {print $2}' opensuse/content >/tmp/$USER-opensuseversion.tmp
		cp opensuse/boot/i386/loader/linux multicd-working/boot/opensuse/linux
		cp opensuse/boot/i386/loader/initrd multicd-working/boot/opensuse/initrd
		umount opensuse
		rmdir opensuse
	fi
elif [ $1 = writecfg ];then
if [ -f opensuse.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label opensuse-kernel
  menu label Install ^openSUSE (from mirrors.kernel.org)
  kernel /boot/opensuse/linux
EOF
echo "  append initrd=/boot/opensuse/initrd splash=silent showopts install=ftp://mirrors.kernel.org/opensuse/distribution/"$(cat /tmp/$USER-opensuseversion.tmp)"/repo/oss" >> multicd-working/boot/isolinux/isolinux.cfg
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label opensuse
  menu label Install openSUSE (specify mirror)
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
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
