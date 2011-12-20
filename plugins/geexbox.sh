#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#GeeXboX plugin for multicd.sh
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
if [ $1 = scan ];then
	if [ -f geexbox.iso ];then
		echo "GeeXboX"
	fi
elif [ $1 = copy ];then
	if [ -f geexbox.iso ];then
		echo "Copying GeeXboX..."
		mcdmount geexbox
		cp -r "${MNT}"/geexbox/GEEXBOX "${WORK}"/ #Everything GeeXbox has is in one folder. :)
		umcdmount geexbox
	fi
elif [ $1 = writecfg ];then
if [ -f geexbox.iso ];then
echo "label gbox
	menu label ^GeeXboX
	com32 vesamenu.c32
	append gbox.menu
" >> "${WORK}"/boot/isolinux/isolinux.cfg
echo "PROMPT 0

TIMEOUT 20

MENU BACKGROUND /GEEXBOX/boot/splash.png
MENU TITLE Welcome to GeeXboX i386 (C) 2002-2009
MENU VSHIFT 11
MENU ROWS 6
MENU TABMSGROW 15
MENU CMDLINEROW 14
MENU HELPMSGROW 16
MENU TABMSG Press [Tab] to edit options, [F1] for boot options.
MENU COLOR sel 7;37;40 #e0000000 #fa833b all
MENU COLOR border 30;44 #00000000 #00000000 none

LABEL geexbox
  MENU LABEL Start GeeXboX ...
  KERNEL /GEEXBOX/boot/vmlinuz
  APPEND initrd=/GEEXBOX/boot/initrd.gz root=/dev/ram0 rw rdinit=linuxrc boot=cdrom lang=en remote=atiusb receiver=atiusb keymap=qwerty splash=silent vga=789 video=vesafb:ywrap,mtrr quiet

LABEL hdtv
  MENU DEFAULT
  MENU LABEL Start GeeXboX for HDTV ...
  KERNEL /GEEXBOX/boot/vmlinuz
  APPEND initrd=/GEEXBOX/boot/initrd.gz root=/dev/ram0 rw rdinit=linuxrc boot=cdrom lang=en remote=atiusb receiver=atiusb keymap=qwerty splash=silent vga=789 video=vesafb:ywrap,mtrr hdtv quiet

LABEL install
  MENU LABEL Install GeeXboX to disk ...
  KERNEL /GEEXBOX/boot/vmlinuz
  APPEND initrd=/GEEXBOX/boot/initrd.gz root=/dev/ram0 rw rdinit=linuxrc boot=cdrom lang=en remote=atiusb receiver=atiusb keymap=qwerty splash=silent vga=789 video=vesafb:ywrap,mtrr installator quiet

#CFG#LABEL configure
#CFG#  MENU LABEL Reconfigure a GeeXboX installation ...
#CFG#  KERNEL /GEEXBOX/boot/vmlinuz
#CFG#  APPEND initrd=/GEEXBOX/boot/initrd.gz root=/dev/ram0 rw rdinit=linuxrc boot=cdrom lang=en remote=atiusb receiver=atiusb keymap=qwerty splash=silent vga=789 video=vesafb:ywrap,mtrr configure

MENU SEPARATOR

LABEL debug
  MENU LABEL Start in debugging mode ...
  KERNEL /GEEXBOX/boot/vmlinuz
  APPEND initrd=/GEEXBOX/boot/initrd.gz root=/dev/ram0 rw rdinit=linuxrc boot=cdrom lang=en remote=atiusb receiver=atiusb keymap=qwerty splash=0 vga=789 video=vesafb:ywrap,mtrr debugging

LABEL hdtvdebug
  MENU LABEL Start HDTV edition in debugging mode ...
  KERNEL /GEEXBOX/boot/vmlinuz
  APPEND initrd=/GEEXBOX/boot/initrd.gz root=/dev/ram0 rw rdinit=linuxrc boot=cdrom lang=en remote=atiusb receiver=atiusb keymap=qwerty splash=0 vga=789 video=vesafb:ywrap,mtrr hdtv debugging

F1 help.msg #00000000
" > "${WORK}"/boot/isolinux/gbox.menu
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
