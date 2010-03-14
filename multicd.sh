#!/bin/bash
if [ $(whoami) != "root" ];then
	if uname|grep -qi CYGWIN;then
		echo "Cygwin is not supported at the moment."
	else
		echo "This script must be run as root, so it can mount ISO images on the filesystem during the building process."
		exit 1
	fi
fi
set -e
#multicd.sh 5.3
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

if [ -d tags ];then rm -r tags;fi
mkdir -p tags/puppies

if echo $* | grep -q "\bmd5\b";then
 MD5=1
else
 if echo $* | grep -q "\bc\b";then
  MD5=1
 else
  MD5=0
 fi
fi
if echo $* | grep -q "\bm\b";then
 MEMTEST=0
else
 MEMTEST=1
fi
if echo $* | grep -q "\bv\b";then
 VERBOSE=1
 echo > tags/verbose
else
 VERBOSE=0
fi
if echo $* | grep -q "\bcondeb\b";then
 CONDEB=1
else
 CONDEB=0
fi
if echo $* | grep -q "\bmodules\b";then
 MODULES=1
else
 MODULES=0
fi

if [ $MODULES = 1 ];then
 if which dialog;then
  dialog --checklist "Slax modules to include:" 13 45 6 \
  002-xorg.lzm Xorg on \
  003-desktop.lzm KDE on \
  004-kdeapps.lzm "KDE applications" on \
  005-koffice.lzm "KDE Office" on \
  006-devel.lzm Development on \
  2> ./slaxlist0
  echo >> ./slaxlist0
  cat ./slaxlist0|sed -e 's/"//g' -e 's/ /\n/g'>./slaxlist
  rm ./slaxlist0
 else
  echo "Please install dialog to use the module selector."
  exit 1
 fi
fi

echo "List of boot options that will be included:"
#START SCAN
for i in plugins/*;do
	[ ! -x $i ]&&chmod +x $i
	$i scan
done
#END SCAN

for i in *.im[agz]; do
 test -r "$i" || continue
 echo $i|sed 's/\.im.//'
done
GAMES=0 #Will be changed if there are games
for i in games/*.im[agz]; do
 test -r "$i" || continue
 echo Game: $(echo $i|sed 's/\.im.//'|sed 's/games\///')
 GAMES=1
done
if [ -f grub.exe ];then
 echo "GRUB4DOS"
fi
if [ $MEMTEST = 1 ];then
 echo "Memtest86+"
fi

echo
echo "Continuing in 3 seconds - press Ctrl+C to cancel"
sleep 3

if [ $(find tags/puppies -maxdepth 1 -type f|wc -l) -gt 1 ] && which dialog &> /dev/null;then
	echo "dialog --radiolist \"Which Puppy variant would you like to be installable to HD from the disc?\" 13 45 6 \\">puppychooser
	for i in tags/puppies/*;do
		echo $(echo $i|sed -e 's/tags\/puppies\///g') \"\" off \\ >> puppychooser
	done
	echo "2> puppyresult" >> puppychooser
	sh puppychooser
	echo>tags/puppies/$(cat puppyresult).inroot
	rm puppychooser puppyresult
fi
if [ $(find tags/puppies -maxdepth 1 -type f|wc -l) -eq 1 ];then
	NAME=$(ls tags/puppies)
	true>$(find tags/puppies -maxdepth 1 -type f).inroot
fi
if which dialog &> /dev/null;then
	for i in $(find tags -maxdepth 1 -name ubuntu\*);do
		dialog --inputbox "What would you like $(echo $i|sed -e 's/tags\///g') to be called on the CD boot menu?" 8 70 2> $i.name
	done
fi

if [ -d multicd-working ];then
 rm -r multicd-working/*
else
 mkdir multicd-working
fi

#Make sure it exists, you need to put stuff there later
mkdir -p multicd-working/boot/isolinux

#START COPY
for i in plugins/*;do
	[ ! -x $i ]&&chmod +x $i
	$i copy
done
#END COPY

#The below chunk copies floppy images.
j="0"
for i in *.im[agz]; do
	test -r "$i" || continue
	cp "$i" multicd-working/boot/$j.img
	if [ $VERBOSE = 1 ];then
		echo "Saved as "$j".img."
	else
		echo
	fi
	j=$( expr $j + 1 )
done

#This chunk copies floppy images in the "games" folder. They will have their own submenu.
if [ $GAMES = 1 ];then
	k="0"
	mkdir -p multicd-working/boot/games
	for i in games/*.im[agz]; do
		test -r "$i" || continue
		echo -n Copying $(echo $i|sed 's/\.im.//'|sed 's/games\///')"... "
		cp "$i" multicd-working/boot/games/$k.img
		if [ $VERBOSE = 1 ];then
			echo "Saved as games/"$k".img."
		else
			echo
		fi
		k=$( expr $k + 1 )
	done
fi

if [ -f grub.exe ];then
 echo "Copying GRUB4DOS..."
 cp grub.exe multicd-working/boot/grub.exe
fi

echo "Downloading SYSLINUX..."
if [ -f syslinux.tar.gz ];then
	cp syslinux.tar.gz /tmp/syslinux.tar.gz
else
	if [ $VERBOSE != 0 ];then
		wget -O /tmp/syslinux.tar.gz ftp://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-*.tar.gz
	else
		wget -qO /tmp/syslinux.tar.gz ftp://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-*.tar.gz
	fi
fi
if [ $? = 0 ];then
	echo "Unpacking and copying files..."
	tar -C /tmp -xzf /tmp/syslinux.tar.gz
	cp /tmp/syslinux-*/core/isolinux.bin multicd-working/boot/isolinux/
	cp /tmp/syslinux-*/memdisk/memdisk multicd-working/boot/isolinux/
	cp /tmp/syslinux-*/com32/menu/menu.c32 multicd-working/boot/isolinux/
	cp /tmp/syslinux-*/com32/menu/vesamenu.c32 multicd-working/boot/isolinux/
	cp /tmp/syslinux-*/com32/modules/chain.c32 multicd-working/boot/isolinux/
	rm -r /tmp/syslinux-*/ /tmp/syslinux.tar.gz
else
	echo "Downloading of SYSLINUX failed."
	exit 1
fi

if [ $MEMTEST = 1 ];then
 if [ -f memtest ];then
  cp memtest multicd-working/boot/memtest
 else
  echo "Downloading memtest86+ 2.11 from memtest.org..."
  if [ $VERBOSE != 0 ];then
   wget -O- http://www.memtest.org/download/2.11/memtest86+-2.11.bin.gz|gzip -cd>multicd-working/boot/memtest
  else
   wget -qO- http://www.memtest.org/download/2.11/memtest86+-2.11.bin.gz|gzip -cd>multicd-working/boot/memtest
  fi
 fi
fi

echo "Writing isolinux.cfg..."

##BEGIN ISOLINUX MENU CODE##
#The ISOLINUX menu can be rearranged by renaming your plugin scripts - they are processed in alphabetical order.

#BEGIN HEADER#
#Don't move this part. You can change the timeout and menu title, however.
cat > multicd-working/boot/isolinux/isolinux.cfg << "EOF"
DEFAULT menu.c32
TIMEOUT 0
PROMPT 0
menu title Welcome to GNU/Linux!
EOF
#END HEADER#

#BEGIN HD BOOT OPTION#
#If this bugs you, get rid of it.
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label local
menu label Boot from ^hard drive
kernel chain.c32
append hd0
EOF
#END HD BOOT OPTION#

#START WRITE
for i in plugins/*;do
	[ ! -x $i ]&&chmod +x $i
	$i writecfg
done
#END WRITE

#BEGIN DISK IMAGE ENTRY#
j="0"
for i in *.im[agz]; do
  test -r "$i" || continue
  BASICNAME=$(echo $i|sed 's/\.im.//')
  echo label "$BASICNAME" >> multicd-working/boot/isolinux/isolinux.cfg
  echo kernel memdisk >> multicd-working/boot/isolinux/isolinux.cfg
  echo append initrd=/boot/$j.img >> multicd-working/boot/isolinux/isolinux.cfg
  j=$( expr $j + 1 )
done
#END DISK IMAGE ENTRY#

#BEGIN GRUB4DOS ENTRY#
if [ -f multicd-working/boot/grub.exe ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label grub4dos
menu label ^GRUB4DOS
kernel /boot/grub.exe
EOF
elif [ -f multicd-working/boot/riplinux/grub4dos/grub.exe ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label grub4dos
menu label ^GRUB4DOS
kernel /boot/riplinux/grub4dos/grub.exe
EOF
fi
#END GRUB4DOS ENTRY#

#BEGIN GAMES ENTRY#
if [ $GAMES = 1 ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label games
menu label ^Games on disk images
com32 menu.c32
append games.cfg
EOF
fi
#END GAMES ENTRY#

#BEGIN MEMTEST ENTRY#
if [ -f multicd-working/boot/memtest ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label memtest
menu label ^Memtest86+ v2.01
kernel /boot/memtest
EOF
fi
#END MEMTEST ENTRY#
##END ISOLINUX MENU CODE##

if [ $GAMES = 1 ];then
k="0"
cat > multicd-working/boot/isolinux/games.cfg << "EOF"
default menu.c32
timeout 300

menu title "Choose a game to play:"
EOF
for i in games/*.im[agz]; do
  test -r "$i" || continue
  BASICNAME=$(echo $i|sed 's/\.im.//'|sed 's/games\///')
  echo label "$BASICNAME" >> multicd-working/boot/isolinux/games.cfg
  echo kernel memdisk >> multicd-working/boot/isolinux/games.cfg
  echo append initrd=/boot/games/$k.img >> multicd-working/boot/isolinux/games.cfg
  k=$( expr $k + 1 )
done
cat >> multicd-working/boot/isolinux/games.cfg << "EOF"
label back
menu label Back to main menu
com32 menu.c32
append isolinux.cfg
EOF
fi

if [ -d includes ];then
 echo "Copying includes..."
 cp -r includes/* multicd-working/
fi

if [ $MD5 = 1 ];then
 echo "Generating MD5 checksums..."
 if [ $VERBOSE != 0 ];then
  find multicd-working/ -type f -not -name md5sum.txt -not -name boot.cat -not -name isolinux.bin \
  -exec md5sum '{}' \; | sed 's/multicd-working\///g' | tee multicd-working/md5sum.txt
 else
  find multicd-working/ -type f -not -name md5sum.txt -not -name boot.cat -not -name isolinux.bin\
  -exec md5sum '{}' \; | sed 's/multicd-working\///g' > multicd-working/md5sum.txt
 fi
fi

if which genisoimage > /dev/null;then
 GENERATOR="genisoimage"
elif which mkisofs > /dev/null;then
 GENERATOR="mkisofs"
else
 echo "Neither genisoimage nor mkisofs was found."
 exit 1
fi
if [ -d multicd-working/boot/trinity ];then
 ISOLABEL=TRK_3.3
else
 ISOLABEL=GNULinux
fi
echo "Building CD image..."
if [ $VERBOSE != 0 ];then
 $GENERATOR -o multicd.iso \
 -b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat \
 -no-emul-boot -boot-load-size 4 -boot-info-table \
 -r -J -l -V "$ISOLABEL" multicd-working/
else
 $GENERATOR -o multicd.iso \
 -b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat \
 -no-emul-boot -boot-load-size 4 -boot-info-table \
 -r -J -l -quiet -V "$ISOLABEL" multicd-working/
fi
rm -r multicd-working/
chmod 666 multicd.iso
rm -r tags
#END SCRIPT
