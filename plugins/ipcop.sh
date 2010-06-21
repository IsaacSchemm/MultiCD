#!/bin/sh
set -e
#IPCop plugin for multicd.sh
#version 5.6
#Copyright (c) 2010 maybeway36
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
	if [ -f ipcop.iso ];then
		echo "IPCop"
	fi
elif [ $1 = copy ];then
	if [ -f ipcop.iso ];then
		echo "Copying IPCop..."
		if [ ! -d ipcop ];then
			mkdir ipcop
		fi
		if grep -q "`pwd`/ipcop" /etc/mtab ; then
			umount ipcop
		fi
		mount -o loop ipcop.iso ipcop/
		cp -r ipcop/boot/isolinux multicd-working/boot/ipcop
		if [ -d multicd-working/images ];then
			echo "There is already a folder called \"images\". Are you adding another Red Hat-based distro?"
			echo "Copying anyway - be warned that on the final CD, something might not work properly."
		fi
		cp -r ipcop/images multicd-working/
		cp ipcop/*.tgz multicd-working
		cp -r ipcop/doc multicd-working/boot/ipcop/ || true
		cp ipcop/*.txt multicd-working/boot/ipcop/ || true
		umount ipcop
		rmdir ipcop
	fi
elif [ $1 = writecfg ];then
if [ -f ipcop.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label ipcopmenu
menu label --> ^IPCop
config /boot/isolinux/ipcop.cfg
EOF
cat > multicd-working/boot/isolinux/ipcop.cfg << "EOF"
TIMEOUT 5000
F1 /boot/ipcop/f1.txt
F2 /boot/ipcop/f2.txt
F3 /boot/ipcop/f3.txt
DISPLAY /boot/ipcop/f1.txt
PROMPT 1
DEFAULT /boot/ipcop/vmlinuz
APPEND ide=nodma initrd=/boot/ipcop/instroot.gz root=/dev/ram0 rw
LABEL nopcmcia 
  KERNEL /boot/ipcop/vmlinuz
  APPEND ide=nodma initrd=/boot/ipcop/instroot.gz root=/dev/ram0 rw nopcmcia
LABEL noscsi
  KERNEL /boot/ipcop/vmlinuz
  APPEND ide=nodma initrd=/boot/ipcop/instroot.gz root=/dev/ram0 rw scsi=none
LABEL nousb
  KERNEL /boot/ipcop/vmlinuz
  APPEND ide=nodma initrd=/boot/ipcop/instroot.gz root=/dev/ram0 rw nousb
LABEL nousborpcmcia
  KERNEL v/boot/ipcop/mlinuz
  APPEND ide=nodma initrd=/boot/ipcop/instroot.gz root=/dev/ram0 rw nousb nopcmcia
LABEL dma
  KERNEL /boot/ipcop/vmlinuz
  APPEND initrd=/boot/ipcop/instroot.gz root=/dev/ram0 rw
LABEL memtest
  KERNEL /boot/memtest
  APPEND -
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
