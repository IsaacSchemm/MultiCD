#!/bin/sh
#Tails plugin for multicd.sh
#https://tails.boum.org/
#version 20150623
if [ $1 = links ];then
	echo "tails.iso tails.debian.iso Tails"
	echo "tails-*.iso tails.debian.iso Tails_(*)"
fi

