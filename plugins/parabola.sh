#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Parabola GNU/Linux-libre plugin for multicd.sh
#version 20150613
#Copyright (c) 2015 Isaac Schemm
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
	echo "parabola-*.iso parabola.iso Parabola_GNU/Linux-libre (*)"
	echo "talkingparabola-*.iso parabola.iso Parabola_GNU/Linux-libre (*)"
elif [ $1 = scan ];then
	if [ -f parabola.iso ];then
		echo "Parabola GNU/Linux-libre"
	fi
elif [ $1 = copy ];then
	if [ -f parabola.iso ];then
		echo "Copying Parabola GNU/Linux-libre..."
		mcdmount parabola
		mcdcp -r "${MNT}"/parabola/parabola "${WORK}"
		umcdmount parabola
	fi
elif [ $1 = writecfg ];then
if [ -f parabola.iso ];then
	if [ -f "${TAGS}"/parabola.name ] && [ "$(cat "${TAGS}"/parabola.name)" != "" ];then
		ISONAME=$(cat "${TAGS}"/parabola.name) #User-entered name
	elif [ -f parabola.defaultname ] && [ "$(cat parabola.defaultname)" != "" ];then
		ISONAME=$(cat parabola.defaultname) #Default name based on the automatic links made in isoaliases()
	else
		ISONAME="Parabola GNU/Linux-libre" #Fallback name
	fi
echo "LABEL loadconfig
  MENU LABEL $ISONAME
  CONFIG /parabola/boot/syslinux/parabolaiso.cfg
  APPEND /parabola/
" >> "${WORK}"/boot/isolinux/isolinux.cfg
perl -pi -e "s/parabolaisolabel=[^ ]*/parabolaisolabel=$CDLABEL/g" "${WORK}"/parabola/boot/syslinux/*.cfg
fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
