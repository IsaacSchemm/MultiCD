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

isoaliases () {
true > $TAGS/linklist
#START LINKS#
for i in $MCDDIR/plugins/*;do
	if ! ($i links|grep -q Usage);then
		$i links >> $TAGS/linklist
	fi
done
#END LINKS#
cat $TAGS/linklist|while read i;do
	DEFAULTNAME=$(echo "$i"|awk '{print $NF}')
	IM2=$(echo "$i"|awk '{LESS=NF-1; print $LESS}') #What should be linked to
	IM1=$(echo $i|awk '{LESS=NF-1; for (i=1; i<LESS; i++) print $i }') #Prints all except the last 2 fields. $i is NOT surrounded by quotes, so wildcards are expanded.
	if !( echo $IM1 | grep -q '\*' ) && [ ! -e $IM2 ];then #IM1 exists (i.e. the asterisk got expanded) and IM2 doesn't exist yet
		COUNTER=0
		for j in $IM1;do
			if [ $COUNTER = 0 ];then
				LINKTO=$IM2
			else
				LINKTO=${COUNTER}_${IM2} #More than one (i.e. Ubuntu)
			fi
			if [ -e "$j" ] && ln -s $j $LINKTO;then
				ISOBASENAME=$(echo $LINKTO|sed -e 's/\.iso//g')
				touch $TAGS/madelinks #This is to make multicd.sh pause for 1 second so the notifications are readable
				CUTOUT1=$(echo "$i"|awk 'BEGIN {FS = "*"} ; {print $1}') #The parts of the ISO name before the asterisk
				CUTOUT2=$(echo "$i"|awk '{print $1}'|awk 'BEGIN {FS = "*"} ; {print $2}') #The parts after the asterisk
				VERSION=$(echo "$j"|awk '{sub(/'"$CUTOUT1"'/,"");sub(/'"$CUTOUT2"'/,"");print}') #Cuts out whatever the asterisk represents (which will be the version number)
				if [ "$VERSION" != "*" ] && [ "$VERSION" != "$j" ];then
					echo $VERSION > $ISOBASENAME.version #The SystemRescueCD plugin does not use this, but I figure it won't do any harm to have an extra file sitting there.
					echo "Made a link named $LINKTO pointing to $j (version $VERSION)"
				else	
					echo "Made a link named $LINKTO pointing to $j"
					VERSION="*" #Should remain an asterisk in .defaultname file (see below)
				fi
				if [ "$DEFAULTNAME" != "none" ];then
					#The third field of the row will be the default name when multicd.sh asks the user to enter a name.
					#This could also be used by the menu-writing portion of the plugin script if $TAGS/whatever.name is not present.
					#Underscores are replaced with spaces. Asterisks are replaced with the $VERSION found above.
					echo $DEFAULTNAME|sed -e 's/_/ /g' -e "s/\*/$VERSION/g">$ISOBASENAME.defaultname
				fi
			COUNTER=$(($COUNTER+1))
			fi
		done
	fi
done
if [ -f $TAGS/madelinks ];then
	rm $TAGS/madelinks
	sleep 1
fi
}

tinycorecommon () {
	if [ ! -z "$1" ] && [ -f $1.iso ];then
		mcdmount $1
		mkdir $WORK/boot/tinycore
		cp $MNT/$1/boot/bzImage $WORK/boot/tinycore/bzImage #Linux kernel
		cp $MNT/$1/boot/*.gz $WORK/boot/tinycore/ #Copy any initrd there may be - this works for microcore too
		if [ -d $MNT/$1/tce ];then
			cp -r $MNT/$1/tce $WORK/
		fi
		sleep 1
		umcdmount $1
	else
		echo "$0: \"$1\" is empty or not an ISO"
		exit 1
	fi
}
puppycommon () {
	if [ ! -z "$1" ] && [ -f $1.iso ];then
		mcdmount $1
		#The installer will only work if Puppy is in the root dir of the disc
		if [ -f $TAGS/puppies/$1.inroot ];then
			cp $MNT/$1/*.sfs $WORK/
			cp $MNT/$1/vmlinuz $WORK/vmlinuz
			cp $MNT/$1/initrd.gz $WORK/initrd.gz
		else
			mkdir $WORK/$1
			cp $MNT/$1/*.sfs $WORK/$1/
			cp $MNT/$1/vmlinuz $WORK/$1/vmlinuz
			cp $MNT/$1/initrd.gz $WORK/$1/initrd.gz
		fi
		umcdmount $1
	else
		echo "$0: \"$1\" is empty or not an ISO"
		exit 1
	fi
}
ubuntucommon () {
	if [ ! -z "$1" ] && [ -f $1.iso ];then
		mcdmount $1
		cp -R $MNT/$1/casper $WORK/boot/$1 #Live system
		if [ -d $MNT/$1/preseed ];then
			cp -R $MNT/$1/preseed $WORK/boot/$1
		fi
		# Fix the isolinux.cfg
		if [ -f $MNT/$1/isolinux/text.cfg ];then
			UBUCFG=text.cfg
		elif [ -f $MNT/$1/isolinux/txt.cfg ];then
			UBUCFG=txt.cfg
		else
			UBUCFG=isolinux.cfg #For custom-made live CDs
		fi
		cp $MNT/$1/isolinux/$UBUCFG $WORK/boot/$1/$1.cfg
		sed -i "s@default live@default menu.c32@g" $WORK/boot/$1/$1.cfg #Show menu instead of boot: prompt
		sed -i "s@file=/cdrom/preseed/@file=/cdrom/boot/$1/preseed/@g" $WORK/boot/$1/$1.cfg #Preseed folder moved - not sure if ubiquity uses this
		sed -i "s^initrd=/casper/^live-media-path=/boot/$1 ignore_uuid initrd=/boot/$1/^g" $WORK/boot/$1/$1.cfg #Initrd moved, ignore_uuid added
		sed -i "s^kernel /casper/^kernel /boot/$1/^g" $WORK/boot/$1/$1.cfg #Kernel moved
		if [ $(cat $TAGS/lang) != en ];then
			sed -i "s^initrd=/boot/$1/^debian-installer/language=$(cat $TAGS/lang) console-setup/layoutcode?=$(cat $TAGS/lang) initrd=/boot/$1/^g" $WORK/boot/$1/$1.cfg #Add language codes to cmdline
		fi
		umcdmount $1
	else
		echo "$0: \"$1\" is empty or not an ISO"
		exit 1
	fi
}
#END FUNCTIONS
