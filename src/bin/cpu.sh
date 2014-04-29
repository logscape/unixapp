#!/bin/sh
# 
. `dirname $0`/common.sh

#HEADER='Cpu	CpuUserPct	CpuNicePct	CpuSystemPct	CpuIOWaitPct	CpuIdlePct'
#HEADERIZE="BEGIN {print \"$HEADER\"}"
PRINTF='END {printf "%s\t%s\t%s\t%s\t%s\t%s\n", cpu, pctUser, pctNice, pctSystem, pctIowait, pctIdle}'

if [ "x$KERNEL" = "xLinux" ] ; then
	queryHaveCommand sar
	FOUND_SAR=$?
	queryHaveCommand mpstat
	FOUND_MPSTAT=$?
    if [ $FOUND_SAR -eq 0 ] ; then
		CMD='sar 2 5'
		FORMAT='{cpu=$2; pctUser=$3; pctNice=$4; pctSystem=$5; pctIowait=$6; pctIdle=$8}'
	elif [ $FOUND_MPSTAT -eq 0 ] ; then
		CMD='mpstat 1 1'
		FORMAT='{cpu=$2; pctUser=$3; pctNice=$4; pctSystem=$5; pctIowait=$6; pctIdle=$11}'
	else
		failLackMultipleCommands sar mpstat
	fi
	FILTER='/[lL]inux|^\s*$/ {next;} /[aA]verage/ '
elif [ "x$KERNEL" = "xSunOS" ] ; then
	assertHaveCommand vmstat
	CMD='vmstat 1 2'
	FILTER='NR=4'
	FORMAT='{cpu="all"; pctUser=$(NF-2); pctNice="-1"; pctSystem=$(NF-1); pctIowait="-1"; pctIdle=NF}'
elif [ "x$KERNEL" = "xDarwin" ] ; then
	assertHaveCommand sar
	CMD='sar -u 1'
	FILTER='($0 !~ "Average") {next}'
	FORMAT='{cpu="all"; pctUser=$2; pctNice=$3; pctSystem=$4; pctIdle=$5; pctIowait="-1"}'
elif [ "x$KERNEL" = "xFreeBSD" ] ; then
	assertHaveCommand iostat
	CMD='iostat -C -c 2'
	FILTER='(NR<4) {next}'
	FORMAT='{cpu="all"; pctUser=$(NF-4); pctNice=$(NF-3); pctSystem=$(NF-2); pctIdle=$NF; pctIowait="-1"}'
fi

$CMD | tee $TEE_DEST | $AWK "$FILTER $FORMAT $PRINTF"
#echo "Cmd = [$CMD];  | $AWK '$FILTER $FORMAT $PRINTF'" >> $TEE_DEST
