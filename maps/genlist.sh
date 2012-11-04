#!/bin/bash
for i in *.ktl
do
	lang=$(echo $i | sed -e 's!.ktl!!g')
	echo "label $lang"
	echo "  kernel kbdmap.c32"
	echo "  append maps/$i"
done
