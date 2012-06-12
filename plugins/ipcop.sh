#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#IPCop plugin for multicd.sh
#version 20120612
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
	echo "ipcop-*-install-cd.i486.iso ipcop.iso none"
elif [ $1 = scan ];then
	if [ -f ipcop.iso ];then
		echo "IPCop"
	fi
elif [ $1 = copy ];then
	if [ -f ipcop.iso ];then
		echo "Copying IPCop..."
		mcdmount ipcop
		cp -r "${MNT}"/ipcop/boot/isolinux "${WORK}"/boot/ipcop
		if [ -d "${WORK}"/images ];then
			echo "There is already a folder called \"images\". Are you adding another Red Hat-based distro?"
			echo "Copying anyway - be warned that on the final CD, something might not work properly."
		fi
		cp -r "${MNT}"/ipcop/images "${WORK}"/
		cp "${MNT}"/ipcop/*.tgz "${WORK}" 2> /dev/null || true #for version 1
		cp "${MNT}"/ipcop/*.tar.gz "${WORK}" 2> /dev/null || true #for version 2
		cp -r "${MNT}"/ipcop/doc "${WORK}"/boot/ipcop/ || true
		cp "${MNT}"/ipcop/*.txt "${WORK}"/boot/ipcop/ || true
		umcdmount ipcop
	fi
elif [ $1 = writecfg ];then
	if [ -f ipcop.iso ];then
		if [ -f "${WORK}"/boot/ipcop/instroot.img ];then
			INSTROOT="instroot.img"
		else
			INSTROOT="instroot.gz"
		fi
		echo "label ipcopmenu
		menu label --> ^IPCop
		config /boot/isolinux/ipcop.cfg
		" >> "${WORK}"/boot/isolinux/isolinux.cfg
		echo "TIMEOUT 5000
		F1 /boot/ipcop/f1.txt
		F2 /boot/ipcop/f2.txt
		F3 /boot/ipcop/f3.txt
		DISPLAY /boot/ipcop/f1.txt
		PROMPT 1
		DEFAULT /boot/ipcop/vmlinuz
		APPEND ide=nodma initrd=/boot/ipcop/$INSTROOT root=/dev/ram0 rw
		LABEL nopcmcia 
		  KERNEL /boot/ipcop/vmlinuz
		  APPEND ide=nodma initrd=/boot/ipcop/$INSTROOT root=/dev/ram0 rw nopcmcia
		LABEL noscsi
		  KERNEL /boot/ipcop/vmlinuz
		  APPEND ide=nodma initrd=/boot/ipcop/$INSTROOT root=/dev/ram0 rw scsi=none
		LABEL nousb
		  KERNEL /boot/ipcop/vmlinuz
		  APPEND ide=nodma initrd=/boot/ipcop/$INSTROOT root=/dev/ram0 rw nousb
		LABEL nousborpcmcia
		  KERNEL v/boot/ipcop/mlinuz
		  APPEND ide=nodma initrd=/boot/ipcop/$INSTROOT root=/dev/ram0 rw nousb nopcmcia
		LABEL dma
		  KERNEL /boot/ipcop/vmlinuz
		  APPEND initrd=/boot/ipcop/$INSTROOT root=/dev/ram0 rw
		LABEL memtest
		  KERNEL /boot/memtest
		  APPEND -
		" > "${WORK}"/boot/isolinux/ipcop.cfg
	fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
