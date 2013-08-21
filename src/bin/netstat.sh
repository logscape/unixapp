#!/bin/sh
# 
# 

. `dirname $0`/common.sh

HEADER='Proto  Recv-Q  Send-Q  LocalAddress                    ForeignAddress                  State'
HEADERIZE="BEGIN {print \"$HEADER\"}"
PRINTF='{printf "%-5s  %6s  %6s  %-30.30s  %-30.30s  %-s\n", $1, $2, $3, $4, $5, $6}'
FILL_BLANKS='($1=="udp") {$6="<n/a>"}'

if [ "x$KERNEL" = "xLinux" ] ; then
	CMD='eval netstat -aep 2>/dev/null | egrep "tcp|udp"'
elif [ "x$KERNEL" = "xSunOS" ] ; then
	CMD='netstat -a -f inet -f inet6'
	FIGURE_SECTION='NR==1 {inUDP=1;inTCP=0} /^TCP: IPv/ {inUDP=0;inTCP=1} /^SCTP:/ {exit}'
	FILTER='/: IPv|Local Address|^$|^-----/ {next}'
	FORMAT_UDP='(inUDP) {localAddr=$1; $1="udp"; $2=$3=0; $4=localAddr; $5="*.*"}'
	FORMAT_TCP='(inTCP) {localAddr=$1; foreignAddr=$2; sendQ=$4; recvQ=$6; state=$7; $1="tcp"; $2=recvQ; $3=sendQ; $4=localAddr; $5=foreignAddr; $6=state}'
	FORMAT="$FORMAT_UDP $FORMAT_TCP"
elif [ "x$KERNEL" = "xDarwin" ] ; then
	CMD='eval netstat -aW | egrep "tcp|udp"'
	FORMAT='{gsub("[46]", "", $1)}'
elif [ "x$KERNEL" = "xFreeBSD" ] ; then
	CMD='eval netstat -a | egrep "tcp|udp"'
	FORMAT='{gsub("[46]", "", $1)}'
fi

assertHaveCommand $CMD
$CMD | tee $TEE_DEST | $AWK "$HEADERIZE $FIGURE_SECTION $FILTER $FORMAT $FILL_BLANKS $PRINTF"  header="$HEADER"
echo "Cmd = [$CMD];  | $AWK '$HEADERIZE $FIGURE_SECTION $FILTER $FORMAT $FILL_BLANKS $PRINTF' header=\"$HEADER\"" >> $TEE_DEST
