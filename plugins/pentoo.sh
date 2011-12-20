#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Pentoo plugin for multicd.sh
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

# BUGS
# modules directory is not read correctly, as it is searched for in /
if [ $1 = scan ];then
    if [ -f pentoo.iso ];then
        echo "Pentoo Linux"
    fi
elif [ $1 = copy ];then
    if [ -f pentoo.iso ];then
        echo "Copying Pentoo Linux..."
        mcdmount pentoo

        mkdir -p "${WORK}"/boot/pentoo
        for item in modules tools win32 image.squashfs livecd; do
            cp -r "${MNT}"/pentoo/$item "${WORK}"/boot/pentoo
        done
        for item in pentoo isolinux.cfg pentoo.igz; do
            cp -r "${MNT}"/pentoo/isolinux/$item "${WORK}"/boot/pentoo
        done

        # Fix the isolinux.cfg
        sed -i 's@loop=/image.squashfs@loop=/boot/pentoo/image.squashfs subdir=/boot/pentoo@' "${WORK}"/boot/pentoo/isolinux.cfg
        sed -i 's@kernel @kernel /boot/pentoo/@' "${WORK}"/boot/pentoo/isolinux.cfg
        sed -i 's@initrd=@initrd=/boot/pentoo/@' "${WORK}"/boot/pentoo/isolinux.cfg

        umcdmount pentoo
    fi
elif [ $1 = writecfg ];then
if [ -f pentoo.iso ];then
cat >> "${WORK}"/boot/isolinux/isolinux.cfg << EOF
label pentoo
menu label ---> ^Pentoo Menu
com32 menu.c32
append /boot/pentoo/isolinux.cfg

EOF

cat >> "${WORK}"/boot/pentoo/isolinux.cfg << EOF

label back
menu label Back to main menu
com32 menu.c32
append /boot/isolinux/isolinux.cfg

EOF

fi
else
    echo "Usage: $0 {scan|copy|writecfg}"
    echo "Use only from within multicd.sh or a compatible script!"
    echo "Don't use this plugin script on its own!"
fi
