#!/bin/sh
# 
# 

. `dirname $0`/common.sh

HEADER='Cpu	CpuUserPct	CpuNicePct	CpuSystemPct	CpuIOWaitPct	CpuIdlePct'
HEADERIZE="BEGIN {print \"$HEADER\"}"
PRINTF='{printf "%s\t%s\t%s\t%s\t%s\t%s\n", cpu, pctUser, pctNice, pctSystem, pctIowait, pctIdle}'

if [ "x$KERNEL" = "xLinux" ] ; then
	queryHaveCommand sar
	FOUND_SAR=$?
	queryHaveCommand mpstat
	FOUND_MPSTAT=$?
    if [ $FOUND_SAR -eq 0 ] ; then
		CMD='sar -P ALL 1 1'
		FORMAT='{cpu=$(NF-6); pctUser=$(NF-5); pctNice=$(NF-4); pctSystem=$(NF-3); pctIowait=$(NF-2); pctIdle=$NF}'
	elif [ $FOUND_MPSTAT -eq 0 ] ; then
		CMD='mpstat -P ALL 1 1'
		FORMAT='{cpu=$(NF-9); pctUser=$(NF-8); pctNice=$(NF-7); pctSystem=$(NF-6); pctIowait=$(NF-5); pctIdle=$(NF-1)}'
	else
		failLackMultipleCommands sar mpstat
	fi
	FILTER='/Average|Linux|^$|%/ {next} (NR==1) {next}'
elif [ "x$KERNEL" = "xSunOS" ] ; then
	vmstat 1 2 | awk 'NR==4 {print "all\t"$(NF-1)"\t0\t"$(NF-2)"\t0\t"($NF)}'
	exit
elif [ "x$KERNEL" = "xDarwin" ] ; then
	CMD='sar -u 1'
	assertHaveCommand $CMD
	FILTER='($0 !~ "Average") {next}'
	FORMAT='{cpu="all"; pctUser=$2; pctNice=$3; pctSystem=$4; pctIdle=$5; pctIowait="-1"}'
elif [ "x$KERNEL" = "xFreeBSD" ] ; then
	CMD='iostat -C -c 2'
	assertHaveCommand $CMD
	FILTER='(NR<4) {next}'
	FORMAT='{cpu="all"; pctUser=$(NF-4); pctNice=$(NF-3); pctSystem=$(NF-2); pctIdle=$NF; pctIowait="-1"}'
fi

#$CMD | tee $TEE_DEST | $AWK "$HEADERIZE $FILTER $FORMAT $PRINTF"  header="$HEADER"
#echo "Cmd = [$CMD];  | $AWK '$HEADERIZE $FILTER $FORMAT $PRINTF' header=\"$HEADER\"" >> $TEE_DEST

$CMD | tee $TEE_DEST | $AWK "$FILTER $FORMAT $PRINTF"
echo "Cmd = [$CMD];  | $AWK '$FILTER $FORMAT $PRINTF'" >> $TEE_DEST
