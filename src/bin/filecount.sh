#!/bin/sh
OS=`uname -a`

case "$OS" in 
	*Linux*)
		sar -v 1 3  | awk '{print $2"\t"$3"\t"$4"\t"$5}' | grep -v file
	;;
esac 

