#!/bin/sh
set -e
#Ultimate Boot CD plugin for multicd.sh
#version 5.9
#Copyright (c) 2010 libertyernie
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
	echo "ubcd-*.iso ubcd.iso none"
elif [ $1 = scan ];then
	if [ -f ubcd.iso ];then
		echo "Ultimate Boot CD"
	fi
	if [ -f dban.iso ] && [ -f ubcd.iso ];then
		echo
		echo "Note: Ultimate Boot CD includes DBAN, so it is not necessary alone as well."
		echo "Continuing anyway."
	fi
	if [ -f ntpasswd.iso ] && [ -f ubcd.iso ];then
		echo
		echo "Note: UBCD includes NT Password & Registry Editor, so it is not necessary alone as well."
		echo "Continuing anyway."
	fi
elif [ $1 = copy ];then
	set -e
	if [ -f ubcd.iso ];then
		echo "Copying Ultimate Boot CD..."
		if [ ! -d ubcd ];then
			mkdir ubcd
		fi
		if grep -q "`pwd`/ubcd" /etc/mtab ; then
			umount ubcd
		fi
		mount -o loop ubcd.iso ubcd/
		cp -r ubcd/ubcd multicd-working/
		cp -r ubcd/pmagic multicd-working/
		cp -r ubcd/antivir multicd-working/
		cp ubcd/license.txt multicd-working/ubcd-license.txt
		cp ubcd/boot/syslinux/econfig.c32 multicd-working/boot/isolinux/
		cp ubcd/boot/syslinux/reboot.c32 multicd-working/boot/isolinux/
		for i in multicd-working/ubcd/menus/*/*.cfg multicd-working/ubcd/menus/*/*/*.cfg multicd-working/pmagic/boot/*/*.cfg;do
			perl -pi -e 's/\/boot\/syslinux/\/boot\/isolinux/g' $i
		done
		head -n 1 ubcd/ubcd/menus/syslinux/defaults.cfg | awk '{ print $6 }'>ubcdver.tmp.txt
		#echo "$VERSION" > multicd-working/boot/ubcd/version
		umount ubcd
		rmdir ubcd
	fi
elif [ $1 = writecfg ];then
if [ -f ubcd.iso ];then
VERSION=$(cat ubcdver.tmp.txt)
rm ubcdver.tmp.txt
echo "label ubcd
menu label --> ^Ultimate Boot CD ($VERSION) - Main menu
com32 menu.c32
append /ubcd/menus/isolinux/main.cfg" >> multicd-working/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
