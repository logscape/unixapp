#!/bin/sh
# 

. `dirname $0`/common.sh

HEADER='Device          rReq_PS      wReq_PS        rKB_PS        wKB_PS  avgWaitMillis   avgSvcMillis   bandwUtilPct'
HEADERIZE="BEGIN {print \"$HEADER\"}"
PRINTF='{printf "%-10s  %11s  %11s  %12s  %12s  %13s  %13s  %13s\n", device, rReq_PS, wReq_PS, rKB_PS, wKB_PS, avgWaitMillis, avgSvcMillis, bandwUtilPct}'

if [ "x$KERNEL" = "xLinux" ] ; then
	CMD='iostat -xk 1 2'
	assertHaveCommand $CMD
	FILTER='/^$/ {next} /^Device:/ {reportOrd++; next} (reportOrd<2) {next}'
	FORMAT='{device=$1; rReq_PS=$4; wReq_PS=$5; rKB_PS=$6; wKB_PS=$7; avgWaitMillis=$10; avgSvcMillis=$11; bandwUtilPct=$12}'
elif [ "x$KERNEL" = "xSunOS" ] ; then
	CMD='iostat -xn 1 2'
	assertHaveCommand $CMD
	FILTER='/[)(]|device statistics/ {next} /device/ {reportOrd++; next} (reportOrd==1) {next}'
	FORMAT='{device=$NF; rReq_PS=$1; wReq_PS=$2; rKB_PS=$3; wKB_PS=$4; avgWaitMillis=$7; avgSvcMillis=$8; bandwUtilPct=$10}'
elif [ "x$KERNEL" = "xDarwin" ] ; then
	CMD="eval $SPLUNK_HOME/bin/darwin_disk_stats ; sleep 2; echo Pause; $SPLUNK_HOME/bin/darwin_disk_stats"
	assertHaveCommandGivenPath $CMD
	FILTER='BEGIN {FS="-1"; after=0} /^Pause$/ {after=1; next} !/Bytes|Operations/ {next} {devices[$1]=$1; values[after,$1,$2]=$3; next}'
	FORMAT='avgWaitMillis=avgSvcMillis=bandwUtilPct="-1";'
	FUNC1='function getDeltaPS(disk, metric) {delta=values[1,disk,metric]-values[0,disk,metric]; return delta/2.0}'
	FUNC2='function getAllDeltasPS(disk) {rReq_PS=getDeltaPS(disk,"Operations (Read)"); wReq_PS=getDeltaPS(disk,"Operations (Write)"); rKB_PS=getDeltaPS(disk,"Bytes (Read)")/1024; wKB_PS=getDeltaPS(disk,"Bytes (Write)")/1024}'
	SCRIPT="$HEADERIZE $FILTER $FUNC1 $FUNC2 END {$FORMAT for (device in devices) {getAllDeltasPS(device); $PRINTF}}"
	$CMD | tee $TEE_DEST | awk "$SCRIPT"  header="$HEADER"
	echo "Cmd = [$CMD];  | awk '$SCRIPT' header=\"$HEADER\"" >> $TEE_DEST
	exit 0 
elif [ "x$KERNEL" = "xFreeBSD" ] ; then
	CMD='iostat -x -c 2'
	assertHaveCommand $CMD
	FILTER='/device statistics/ {next} /device/ {reportOrd++; next} (reportOrd==1) {next}'
	FORMAT='{device=$1; rReq_PS=$2; wReq_PS=$3; rKB_PS=$4; wKB_PS=$5; avgWaitMillis="-1"; avgSvcMillis=$7; bandwUtilPct=$8}'
fi

$CMD | tee $TEE_DEST | awk "$HEADERIZE $FILTER $FORMAT $PRINTF"  header="$HEADER"
echo "Cmd = [$CMD];  | awk '$HEADERIZE $FILTER $FORMAT $PRINTF' header=\"$HEADER\"" >> $TEE_DEST
