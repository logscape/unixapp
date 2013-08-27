#!/bin/sh
# 
. `dirname $0`/common.sh

echo $KERNEL

if [ "x$KERNEL"="xLinux" ];then
	`dirname $0`/free-all.sh
elif [ "x$KERNEL" = "xSunOS" ] ; then
	`dirname $0`/free-sunOs.sh
fi
