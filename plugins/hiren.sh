#!/bin/sh
set -e
#Hiren's BootCD (11.0) plugin for multicd.sh
#version 5.9
#Copyright for this script (c) 2010 maybeway36
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
	if [ -f hirens.iso ];then
		echo "Hiren's BootCD (Not open source - do not distribute)"
	fi
	DUPLICATES=false #Initialize variable
	for i in riplinux dban konboot ntpasswd;do
		if [ -f $i.iso ];then
			echo
			echo "Note: Hiren's BootCD already includes $i."
			DUPLICATES=true
		fi
	done
	if $DUPLICATES;then
		echo "Continuing anyway."
		echo
	fi
elif [ $1 = copy ];then
	if [ -f hirens.iso ];then
		echo "Copying Hiren's BootCD..."
		if [ ! -d hirens ];then
			mkdir hirens
		fi
		if grep -q "`pwd`/hirens" /etc/mtab ; then
			umount hirens
		fi
		mount -o loop hirens.iso hirens/
		if [ -f hirens/BootCD.txt ];then
			head -n 1 hirens/BootCD.txt |sed -e 's/\t//g'>tags/hirens.name
		else
			echo "Warning: No BootCD.txt in hirens.iso" 1>&2
			echo "Hiren's BootCD">tags/hirens.name
		fi
		cp -rv hirens/HBCD multicd-working/
		umount hirens;rmdir hirens
	fi
elif [ $1 = writecfg ];then
if [ -f hirens.iso ];then
echo "label hirens
menu label --> ^$(cat tags/hirens.name) - main menu
com32 menu.c32
append /HBCD/isolinux.cfg" >> multicd-working/boot/isolinux/isolinux.cfg
fi
rm tags/hirens.name
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
