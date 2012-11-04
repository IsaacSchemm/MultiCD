#!/bin/bash
set -e
. "${MCDDIR}"/functions.sh
#Caine plugin for multicd.sh
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
if [ $1 = scan ];then
    if [ -f caine.iso ];then
        echo "Caine"
    fi
elif [ $1 = copy ];then
    if [ -f caine.iso ];then
        echo "Copying Caine..."
        mcdmount caine
        cp -r "${MNT}"/caine/casper "${WORK}"/boot/caine #Live system
        cp "${MNT}"/caine/README.diskdefines "${WORK}"/
        mkdir "${WORK}"/CaineFiles
        for item in AutoPlay autorun.exe autorun.inf comdlg32.ocx files license.txt page5 preseed Programs RegOcx4Vista.bat rw_common tabctl32.ocx vbrun60.exe WinTaylor.exe; do
            [[ -a "${MNT}"/caine/$item ]] && cp -r "${MNT}"/caine/$item "${WORK}"/CaineFiles
        done
        umcdmount caine
    fi
elif [ $1 = writecfg ];then
    if [ -f "${TAGS}"/lang ];then
        LANGCODE=$(cat "${TAGS}"/lang)
    else
        LANGCODE=en
    fi
    if [ -f caine.iso ];then
        echo "label caine2 (Computer Aided Investigative Environment)
        kernel /boot/caine/vmlinuz
        initrd /boot/caine/initrd.gz
        append live-media-path=/boot/caine ignore_uuid noprompt persistent BOOT_IMAGE=/casper/vmlinuz file=/cdrom/CaineFiles/custom.seed boot=casper -- debian-installer/language=$LANGCODE console-setup/layoutcode=$LANGCODE
        " >> "${WORK}"/boot/isolinux/isolinux.cfg
    fi
else
    echo "Usage: $0 {scan|copy|writecfg}"
    echo "Use only from within multicd.sh or a compatible script!"
    echo "Don't use this plugin script on its own!"
fi
