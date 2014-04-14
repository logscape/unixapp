#!/bin/sh
# 

. `dirname $0`/common.sh

if [ -f    /etc/ntp.conf ] ; then         # Linux; FreeBSD; Mac OS X maybe
	CONFIG=/etc/ntp.conf
elif [ -f  /etc/inet/ntp.conf ] ; then    # Solaris
	CONFIG=/etc/inet/ntp.conf
elif [ -f  /private/etc/ntp.conf ] ; then # Mac OS X
	CONFIG=/private/etc/ntp.conf
else
	CONFIG=
fi

SERVER_DEFAULT='0.pool.ntp.org'
if [ "x$CONFIG" = "x" ] ; then
	SERVER=$SERVER_DEFAULT
else
	SERVER=`$AWK '/^server / {print $2; exit}' $CONFIG`
	SERVER=${SERVER:-$SERVER_DEFAULT}
fi

echo "CONFIG=$CONFIG, SERVER=$SERVER" >> $TEE_DEST

CMD1='date'
CMD2="ntpdate -q $SERVER"

assertHaveCommand $CMD1
assertHaveCommand $CMD2

$CMD1 | tee -a $TEE_DEST
echo "Cmd1 = [$CMD1]" >> $TEE_DEST

$CMD2 | tee -a $TEE_DEST
echo "Cmd2 = [$CMD2]" >> $TEE_DEST
