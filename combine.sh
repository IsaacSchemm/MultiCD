#!/bin/sh
#combine.sh version 5.7 - combine multicd.sh plugins into one script
#Under MIT/X11 license - see multicd.sh
set -e
if [ ! -f multicd.sh ];then
	echo "No multicd.sh!"
	exit 1
fi
if [ ! -d plugins ];then
	echo "No plugins!"
	exit 1
fi
true > working.sh
chmod +x working.sh
sed -n '/#!\/bin\/bash/,/#START PREPARE/p' multicd.sh >> working.sh
sed -n '/#END PREPARE/,/#START SCAN/p' multicd.sh >> working.sh
for i in $(echo plugins/*.sh|sed -e 's/plugins\/0hello.sh//g');do
	if ! grep -q "LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM," $i;then
		echo "Note: $i may not be under the MIT license. Check its license terms and add them to combined-multicd.sh."
	fi
	head -n 3 $i |tail -n 2 >> working.sh
	sed -n '/\$1 = scan/,/\$1 = copy/p' $i|sed -e '1d' -e '$d' >> working.sh
done
sed -n '/#END SCAN/,/#START COPY/p' multicd.sh >> working.sh
for i in $(echo plugins/*.sh|sed -e 's/plugins\/0hello.sh//g');do
	sed -n '/\$1 = copy/,/\$1 = writecfg/p' $i|sed -e '1d' -e '$d' >> working.sh
done
sed -n '/#END COPY/,/#START WRITE/p' multicd.sh >> working.sh
for i in $(echo plugins/*.sh|sed -e 's/plugins\/0hello.sh//g');do
	sed -n '/\$1 = writecfg/,/scan|copy|writecfg/p' $i|sed -e '1d' -e 'N;$!P;$!D;$d' >> working.sh
done
sed -n '/#END WRITE/,/#END SCRIPT/p' multicd.sh >> working.sh
mv working.sh combined-multicd.sh
