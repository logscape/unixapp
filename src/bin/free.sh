#!/bin/sh
# 
. `dirname $0`/common.sh

if [ "x$KERNEL" = "xSunOS" ] ; then
	`dirname $0`/free-sunOs.sh
else
	`dirname $0`/free-all.sh
fi
