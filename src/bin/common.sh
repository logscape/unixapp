#!/bin/sh
unset LD_PRELOAD LD_LIBRARY_PATH DYLD_LIBRARY_PATH SHLIB_PATH LIBPATH

# # # are we in debug mode?
if [ $# -ge 1 -a "x$1" = "x--debug" ] ; then
	DEBUG=1
	TEE_DEST=`dirname $0`/debug--`basename $0`--`date | sed 's/ /_/g;s/:/-/g'`
else
	DEBUG=0
	TEE_DEST=/dev/null
fi

# # # what OS is this?
KERNEL=`uname -s`


# # # assert we are in a supported OS
AWK=awk
case "x$KERNEL" in
	"xLinux")
		# # # enable check for OS versions, if needed later
		if [ -e /etc/debian_version ]; then DEBIAN=true; else DEBIAN=false; fi

		# # # /sbin/ is often absent in non-root users' PATH, and we want it for ifconfig(8)
		PATH=$PATH:/sbin/
		;;
	"xSunOS")
		# # # enable check for OS versions, if needed later
		if [ `uname -r` = "5.8" ]; then SOLARIS_8=true; else SOLARIS_8=false; fi
		if [ `uname -r` = "5.9" ]; then SOLARIS_9=true; else SOLARIS_9=false; fi

		# # # eschew the antedeluvial awk
		AWK=nawk
		;;
	"xDarwin")
		if [ `sw_vers | sed -En '/ProductVersion/ s/^[^.]+\.([0-9]+)\.[^.]+$/\1/p'` -ge 6 ]; then OSX_GE_SNOW_LEOPARD=true; else OSX_GE_SNOW_LEOPARD=false; fi
		;;
	"xFreeBSD")
		;;
	*)
		echo "UNIX flavor [$KERNEL] unsupported for Splunk *NIX App, quitting" > $TEE_DEST
		exit 1
		;;
esac

# # # check for presence of required commands; we do not assume that which(1) exists, and roll our own
queryHaveCommand () # returns 0 if found, 1 if not
{
	[ "x$1" = "xeval" ] && shift
	for directory in `echo $PATH | sed 's/:/ /g'`
	do
		[ -x $directory/$1 ] && return 0
	done
	return 1
}

failLackCommand ()
{
	echo "Not found command [$1] on this host, quitting" > $TEE_DEST
	exit 1
}

failLackMultipleCommands ()
{
	echo "Not found any of commands [$*] on this host, quitting" > $TEE_DEST
	exit 1
}

assertHaveCommand ()
{
	queryHaveCommand $1
	if [ $? -eq 1 ] ; then
		failLackCommand $1
	fi
}

assertHaveCommandGivenPath ()
{
	[ "x$1" = "xeval" ] && shift
	[ -x $1 ] && return
	echo "Not found commandGivenPath [$1] on this host, quitting" > $TEE_DEST
	exit 1
}

failUnsupportedScript ()
{
	echo "UNIX flavor [$KERNEL] unsupported for this script, quitting" > $TEE_DEST
	exit 0
}

assertInvokerIsSuperuser ()
{
	[ `id -u` -eq 0 ] && return
	echo "Must be superuser to run this script, quitting" > $TEE_DEST
	exit 1
}

# # # check for presence of a few basic commands ubiquitous in our scripts
assertHaveCommand $AWK
assertHaveCommand egrep
