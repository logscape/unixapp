#!/bin/sh
# 
# 

. `dirname $0`/common.sh

HEADER='COMMAND     PID        USER   FD      TYPE             DEVICE     SIZE       NODE NAME'
HEADERIZE='{NR == 1 && $0 = header}'
CMD='lsof -nPs'
PRINTF='{printf "%-15.15s  %-10s  %-15.15s  %-8s %-8s  %-15.15s  %15s  %-20.20s  %-s\n", $1,$2,$3,$4,$5,$6,$7,$8,$9}'

if [ "x$KERNEL" = "xLinux" ] ; then
	FILTER='/Permission denied/ {next} {if ($4 == "NOFD" || $5 == "unknown") next}'
	FILL_BLANKS='{if (NF<9) {node=$7; name=$8; $7="-1"; $8=node; $9=name}}'
elif [ "x$KERNEL" = "xSunOS" ] ; then
	`dirname $0`/lsof_count.sh
	failUnsupportedScript
elif [ "x$KERNEL" = "xDarwin" ] ; then
	FILTER='{if ($5 ~ /KQUEUE|PIPE|PSXSEM/) next}'
	FILL_BLANKS='{if (NF<9) {name=$8; $8="-1"; $9=name}}'
elif [ "x$KERNEL" = "xFreeBSD" ] ; then
	failUnsupportedScript
fi

assertHaveCommand $CMD
$CMD 2>$TEE_DEST | tee $TEE_DEST | awk "$HEADERIZE $FILTER $FILL_BLANKS $PRINTF"  header="$HEADER"
echo "Cmd = [$CMD 2>$TEE_DEST];  | awk '$HEADERIZE $FILTER $FILL_BLANKS $PRINTF' header=\"$HEADER\"" >> $TEE_DEST
