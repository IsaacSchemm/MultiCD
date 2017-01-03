#!/bin/sh
#Trisquel plugin for multicd.sh
#https://trisquel.info
#version 20150405
if [ $1 = links ];then
	echo "trisquel.iso trisquel.ubuntu.iso Trisquel"
	echo "trisquel_*.iso trisquel.ubuntu.iso Trisquel_(*)"
	echo "trisquel-*.iso trisquel.ubuntu.iso Trisquel_(*)"
fi

