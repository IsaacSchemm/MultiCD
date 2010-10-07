#!/bin/sh
mcdmount () {
	# $MNT is defined in multicd.sh and is normally in /tmp
	# $1 is the argument passed to mcdmount - used for both ISO name and mount folder name
	if [ ! -d $MNT/$1 ];then
		mkdir $MNT/$1
	fi
	if grep -q $MNT/$1 /etc/mtab ; then
		umount $MNT/$1
	fi
	mount -o loop $1.iso $MNT/$1/
}
umcdmount () {
	umount $MNT/$1;rmdir $MNT/$1
}
