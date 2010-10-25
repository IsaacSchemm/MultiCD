#!/bin/sh
set -e
if [ $1 = scan ] || [ $1 = copy ] || [ $1 = writecfg ] || [ $1 = category ];then
	exit 0 #This is not a plugin itself
fi

