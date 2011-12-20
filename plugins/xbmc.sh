#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#XBMC plugin for multicd.sh
#version 6.9
#Copyright (c) 2011 Isaac Schemm
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
	echo "xbmc-*-live.iso xbmc.iso none"
elif [ $1 = scan ];then
	if [ -f xbmc.iso ];then
		echo "XBMC"
	fi
elif [ $1 = copy ];then
	if [ -f xbmc.iso ];then
		echo "Copying XBMC..."
		mcdmount xbmc
		cp -r "${MNT}"/xbmc/live "${WORK}"/boot/xbmc
		umcdmount xbmc
		rm "${WORK}"/live/memtest||true
	fi
elif [ $1 = writecfg ];then
if [ -f xbmc.iso ];then
	VERSION=$(getVersion xbmc)
	echo "menu begin >> ^XBMC$VERSION

	label XBMCLive
	menu label ^XBMC Live
	kernel /boot/xbmc/vmlinuz
	initrd /boot/xbmc/initrd.img
	append video=vesafb boot=live xbmc=autostart,nodiskmount splash quiet loglevel=0 persistent quickreboot quickusbmodules notimezone noaccessibility noapparmor noaptcdrom noautologin noxautologin noconsolekeyboard nofastboot nognomepanel nohosts nokpersonalizer nolanguageselector nolocales nonetworking nopowermanagement noprogramcrashes nojockey nosudo noupdatenotifier nouser nopolkitconf noxautoconfig noxscreensaver nopreseed union=aufs live-media-path=/boot/xbmc

	label XBMCLiveSafeMode
	menu label XBMC Live (^Safe Mode)
	kernel /boot/xbmc/vmlinuz
	initrd /boot/xbmc/initrd.img
	append boot=live xbmc=nodiskmount quiet loglevel=0 persistent quickreboot quickusbmodules notimezone noaccessibility noapparmor noaptcdrom noautologin noxautologin noconsolekeyboard nofastboot nognomepanel nohosts nokpersonalizer nolanguageselector nolocales nonetworking nopowermanagement noprogramcrashes nojockey nosudo noupdatenotifier nouser nopolkitconf noxautoconfig noxscreensaver nopreseed union=aufs live-media-path=/boot/xbmc

	menu end" >> "${WORK}"/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
