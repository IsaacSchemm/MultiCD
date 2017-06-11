#!/bin/bash
getISO() {
	#echo $1 #Distro name
	#echo $2 #Choice Label
	#echo $3 #File
	#echo $4 #URL
	clear
	echo "Downloading $2..."
	if ! wget -t 1 -O "${3}" "${4}";then
		echo "Error: could not download $4. Please update the URL in downloader.sh."
		### Left in the loop to main menu commented incase one wants to just loop back on error.
		exit 1
		#downloadisos
	fi
	
	case $1 in
		"Ubuntu") select_ubuntu $1 "$2" ;;
		*) downloadisos ;;
	esac
}
failed() {
	error="No $1 entries yet.";
}
### Important:
### This is the blank entry template for distros
### we support but don't have or can't provide links for.
# select_distronamehere() {
#	failed "$1"
#	return=$error
#	downloadisos "$return"
# }
select_debian() {
	failed "$1"
	return=$error
	downloadisos "$return"
}
select_fedora() {
	failed "$1"
	return=$error
	downloadisos "$return"
}
select_ubuntu() {
	failed "$1"
	return=$error
	
	HEIGHT=50
	WIDTH=70
	TITLE="ISO Selections"
	MENU="Choose an ISO: "
	if [ ! "$2" = "" ];then
		MENU="Last Downloaded ISO: $2"
	fi
	
	ISOS=('12.04.5 Alternate 32bit' \
		  '12.04.5 Alternate 64bit' \
		  '12.04.5 Desktop 32bit' \
		  '12.04.5 Desktop 64bit' \
		  '12.04.5 Server 32bit' \
		  '12.04.5 Server 64bit' \
		  '14.04.5 Desktop 32bit' \
		  '14.04.5 Desktop 64bit' \
		  '14.04.5 Server 32bit' \
		  '14.04.5 Server 64bit' \
		  '16.04.2 Desktop 32bit' \
		  '16.04.2 Desktop 64bit' \
		  '16.04.2 Server 32bit' \
		  '16.04.2 Server 64bit' \
		  '16.10 Desktop 32bit' \
		  '16.10 Desktop 64bit' \
		  '16.10 Server 32bit' \
		  '16.10 Server 64bit' \
		  '17.04 Desktop 32bit' \
		  '17.04 Desktop 64bit' \
		  '17.04 Server 32bit' \
		  '17.04 Server 64bit'
		  );

	COUNT=0
	OPTIONS=()
	for i in "${ISOS[@]}"; do
		OPTIONS+=($COUNT "$i")
		COUNT=$[COUNT+1]
	done
	OPTIONS+=($COUNT "Distro Menu")
	COUNT=$[COUNT+1]
	OPTIONS+=($COUNT "Exit")
	CHOICE_HEIGHT=$[COUNT+3]
	
	CHOICE=$(dialog \
				--no-lines \
				--title "$TITLE" \
				--menu "$MENU" \
				$HEIGHT $WIDTH $CHOICE_HEIGHT \
				"${OPTIONS[@]}" \
				2>&1 >/dev/tty
			)
	
	if [ $CHOICE = $[COUNT-1] ];then
		downloadisos "Returned from $1"
	fi
	if [ $CHOICE = $COUNT ];then
		echo "Leaving Distro Downloader from $1 menu."
		exit 1
	fi
	
	COMMON="http://releases.ubuntu.com/"
	FILE=""
	URL=""

	case $CHOICE in
		0)
			FILE="ubuntu-12.04.5-alternate-i386.iso"
			URL="${COMMON}12.04/${FILE}"
		;;
		1)
			FILE="ubuntu-12.04.5-alternate-amd64.iso"
			URL="${COMMON}12.04/${FILE}"
		;;
		2)
			FILE="ubuntu-12.04.5-desktop-i386.iso"
			URL="${COMMON}12.04/${FILE}"
		;;
		3)
			FILE="ubuntu-12.04.5-desktop-amd64.iso"
			URL="${COMMON}12.04/${FILE}"
		;;
		4)
			FILE="ubuntu-12.04.5-server-i386.iso"
			URL="${COMMON}12.04/${FILE}"
		;;
		5)
			FILE="ubuntu-12.04.5-server-amd64.iso"
			URL="${COMMON}12.04/${FILE}"
		;;
		
		6)
			FILE="ubuntu-14.04.5-desktop-i386.iso"
			URL="${COMMON}14.04/${FILE}"
		;;
		7)
			FILE="ubuntu-14.04.5-desktop-amd64.iso"
			URL="${COMMON}14.04/${FILE}"
		;;
		8)
			FILE="ubuntu-14.04.5-server-i386.iso"
			URL="${COMMON}14.04/${FILE}"
		;;
		9)
			FILE="ubuntu-14.04.5-server-amd64.iso"
			URL="${COMMON}14.04/${FILE}"
		;;
		
		10)
			FILE="ubuntu-16.04.2-desktop-i386.iso"
			URL="${COMMON}16.04/${FILE}"
		;;
		11)
			FILE="ubuntu-16.04.2-desktop-amd64.iso"
			URL="${COMMON}16.04/${FILE}"
		;;
		12)
			FILE="ubuntu-16.04.2-server-i386.iso"
			URL="${COMMON}16.04/${FILE}"
		;;
		13)
			FILE="ubuntu-16.04.2-server-amd64.iso"
			URL="${COMMON}16.04/${FILE}"
		;;
		
		14)
			FILE="ubuntu-16.10-desktop-i386.iso"
			URL="${COMMON}16.10/${FILE}"
		;;
		15)
			FILE="ubuntu-16.10-desktop-amd64.iso"
			URL="${COMMON}16.10/${FILE}"
		;;
		16)
			FILE="ubuntu-16.10-server-i386.iso"
			URL="${COMMON}16.10/${FILE}"
		;;
		17)
			FILE="ubuntu-16.10-server-amd64.iso"
			URL="${COMMON}16.10/${FILE}"
		;;
		
		18)
			FILE="ubuntu-17.04-desktop-i386.iso"
			URL="${COMMON}17.04/${FILE}"
		;;
		19)
			FILE="ubuntu-17.04-desktop-amd64.iso"
			URL="${COMMON}17.04/${FILE}"
		;;
		20)
			FILE="ubuntu-17.04-server-i386.iso"
			URL="${COMMON}17.04/${FILE}"
		;;
		21)
			FILE="ubuntu-17.04-server-amd64.iso"
			URL="${COMMON}17.04/${FILE}"
		;;
	esac
	
	getISO $1 "${ISOS[$CHOICE]}" "$FILE" "$URL"
	
	### If menu fails, drop to main menu.
	downloadisos "$return"
}
distrochoice() {
	### return is the default for any entry not populated with a function.
	### Please use similar templates to existing.
	### (select_ then distro name only in lower case.)
	### Then add Just the name in downloadisos() in the DISTROS array.
	### Keep the array name a singular word for simplicity.
	### Can split revisions out further down.
	
	return="No $1 entries yet or invalid selection."	
	case $1 in
		"Debian") select_debian $1 ;;
		"Fedora") select_fedora $1 ;;
		"Ubuntu") select_ubuntu $1 ;;
	esac
	downloadisos "$return"
}
### Main function. Entry point for this file.
downloadisos() {
	if ! which dialog &> /dev/null;then
		echo "You must install dialog to use the interactive options."
		exit 1
	fi

	HEIGHT=50
	WIDTH=70
	TITLE="Distro Selections"
	MENU="Choose a Distro: "$1
	
	### Add distro name here. Singular word for simplicity.
	DISTROS=('Debian' 'Fedora' 'Ubuntu');

	COUNT=0
	OPTIONS=()
	for i in "${DISTROS[@]}"; do
		OPTIONS+=($COUNT "$i")
		COUNT=$[COUNT+1]
	done
	OPTIONS+=($COUNT "Exit")
	CHOICE_HEIGHT=$[COUNT+3]
	
	CHOICE=$(dialog \
				--no-lines \
				--title "$TITLE" \
				--menu "$MENU" \
				$HEIGHT $WIDTH $CHOICE_HEIGHT \
				"${OPTIONS[@]}" \
				2>&1 >/dev/tty
			)
	
	if [ $CHOICE = $COUNT ];then
		echo "Leaving Distro Downloader from main menu."
		exit 1
	fi
	distrochoice ${DISTROS[$CHOICE]}
	
	## Clean exit on menu fail.
	exit 1
}
