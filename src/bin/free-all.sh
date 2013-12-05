#!/bin/sh
#
#

. `dirname $0`/common.sh

HEADER='memTotalMB memUsedMB memSharedMB memBuffMB memCachedMB swapTotalMB swapUsedMB'
HEADERIZE="BEGIN {print \"$HEADER\"}"
PRINTF='END {printf "%d\t%d\t%d\t%d\t%d\t%d\t%d\n", memTotalMB, memUsedMB, memSharedMB, memBuffMB, memCachedMB, swapTotalMB, swapUsedMB}'

assertHaveCommand free
CMD='free -m -o'

PARSE_1='NR==2 {memTotalMB=$2; memUsedMB=$3; memSharedMB=$5; memBuffMB=$6; memCachedMB=$7;}'
PARSE_2='NR==3 {swapTotalMB=$2; swapUsedMB=$3}'

MASSAGE="$PARSE_1 $PARSE_2"

$CMD | tee $TEE_DEST | $AWK "$MASSAGE $FILL_BLANKS $PRINTF"
#echo "Cmd = [$CMD];  | $AWK '$MASSAGE $FILL_BLANKS $PRINTF'" >> $TEE_DEST
