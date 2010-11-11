#!/bin/sh
#combine.sh version 6.2 - combine multicd.sh plugins into one script
#Under MIT/X11 license - see multicd.sh
set -e
if [ ! -f multicd.sh ] || [ ! -d plugins ] || [ -d functions.sh ];then
	echo "The files multicd.sh and functions.sh and the plugins folder must be present."
	exit 1
fi
rm working*.sh 2>/dev/null ||true
sed -n '/#!\/bin\/bash/,/#START PREPARE/p' multicd.sh > working0.sh
sed -n '/#!\/bin\/sh/,/#START LINKS/p' functions.sh >> working0.sh
sed -n '/#END LINKS/,/#END FUNCTIONS/p' functions.sh >> working2.sh
sed -n '/#END PREPARE/,/#START SCAN/p' multicd.sh >> working2.sh
sed -n '/#END SCAN/,/#START COPY/p' multicd.sh > working4.sh
sed -n '/#END COPY/,/#START WRITE/p' multicd.sh > working6.sh
sed -n '/#END WRITE/,/#END SCRIPT/p' multicd.sh > working8.sh
for i in $(echo plugins/*.sh);do
	if grep -q 'scan|copy|writecfg' $i;then
		if ! grep -q "LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM," $i;then
			echo "Note: $i may not be under the MIT license. Check its license terms and add them to combined-multicd.sh."
		fi
		head -n 3 $i |tail -n 2 >> working1.sh #Plugin title
		if grep '\$1 = links' $i;then
			sed -n '/\$1 = links/,/\$1 = scan/p' $i|sed -e '1d' -e '$d' >> working1.sh #Links portion
		fi
		sed -n '/\$1 = scan/,/\$1 = copy/p' $i|sed -e '1d' -e '$d' >> working3.sh #Scan portion
		sed -n '/\$1 = copy/,/\$1 = writecfg/p' $i|sed -e '1d' -e '$d' >> working5.sh #Copy portion
		sed -n '/\$1 = writecfg/,/scan|copy|writecfg/p' $i|sed -e '1d' -e 'N;$!P;$!D;$d' >> working7.sh #isolinux.cfg portion
	else
		echo "Note: $i not being included (it doesn't seem to be a real plugin, because it doesn't contain the string \"scan|copy|writecfg\".)"
	fi
done
sed -i -e 's/$/ >> $TAGS\/linklist/g' working1.sh
cat working[012345678].sh > combined-multicd.sh
rm working[0123456].sh
sed -i -e 's^\. \./functions\.sh^^g' combined-multicd.sh
sed -i -e 's^\. \./isoaliases\.sh^^g' combined-multicd.sh
