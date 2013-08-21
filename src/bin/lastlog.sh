#!/bin/sh
# 
# 

. `dirname $0`/common.sh

HEADER='USERNAME                        FROM                            LATEST'
HEADERIZE="BEGIN {print \"$HEADER\"}"
PRINTF='{printf "%-30s  %-30.30s  %-s\n", username, from, latest}'

if [ "x$KERNEL" = "xLinux" ] ; then
	CMD='lastlog'
	FILTER='/Never logged in/ {next} (NR==1) {next}'
	FORMAT='{username = $1; from = (NF==9) ? $3 : "<console>"; latest=$(NF-4) " " $(NF-3) " " $(NF-2) " " $NF}'
elif [ "x$KERNEL" = "xSunOS" ] ; then
	CMD='last -n 999'
	FILTER='{if ($0 == "") exit; if ($1 ~ /reboot|shutdown/ || $1 in users) next; users[$1]=1}'
	FORMAT='{username = $1; from = (NF==10) ? $3 : "<console>"; latest = $(NF-6) " " $(NF-5) " " $(NF-4) " " $(NF-3)}'
elif [ "x$KERNEL" = "xDarwin" ] ; then
	CMD='last -99'
	FILTER='{if ($0 == "") exit; if ($1 ~ /reboot|shutdown/ || $1 in users) next; users[$1]=1}'
	FORMAT='{username = $1; from = ($0 !~ /                /) ? $3 : "<console>"; latest = $(NF-6) " " $(NF-5) " " $(NF-4) " " $(NF-3)}'
elif [ "x$KERNEL" = "xFreeBSD" ] ; then
	CMD='lastlogin'
	FORMAT='{username = $1; from = (NF==8) ? $3 : "<console>"; latest=$(NF-4) " " $(NF-3) " " $(NF-2) " " $(NF-1) " " $NF}'
fi

assertHaveCommand $CMD
$CMD | tee $TEE_DEST | $AWK "$HEADERIZE $FILTER $FORMAT $PRINTF"  header="$HEADER"
echo "Cmd = [$CMD];  | $AWK '$HEADERIZE $FILTER $FORMAT $PRINTF' header=\"$HEADER\"" >> $TEE_DEST
