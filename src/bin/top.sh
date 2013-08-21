#!/bin/sh
# 
# 

. `dirname $0`/common.sh

HEADER='   PID  USER              PR    NI    VIRT     RES     SHR   S  pctCPU  pctMEM       cpuTIME  COMMAND'
PRINTF='{printf "%6s  %-14s  %4s  %4s  %6s  %6s  %6s  %2s  %6s  %6s  %12s  %-s\n", $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12}'

CMD='top'

if [ "x$KERNEL" = "xLinux" ] ; then
	CMD='top -bn 1'
	FILTER='{if (NR < 7) next}'
	HEADERIZE='{NR == 7 && $0 = header}'
elif [ "x$KERNEL" = "xSunOS" ] ; then
	CMD='prstat -n 999 1 1'
	HEADERIZE="BEGIN {print \"$HEADER\"}"
	FILTER='(NR==1) {next} /^Total:|^$/ {exit}'
	FORMAT_DOMAIN='{virt=$3; res=$4; stateRaw=$5; pr=$6; ni=$7; cpuTIME=$8; pctCPU=0.0+$9; sub("/.*$", "", $10); command=$10 ? $10 : "<n/a>"}'
	SPECIFY_STATES_MAP='BEGIN {map["sleep"]="-1"; map["stop"]="-1"; map["zombie"]="-1"; map["wait"]="-1"; map["cpu"]="-1"}'
	MAP_STATE='{sub("[0-9]+$", "", stateRaw); state=map[stateRaw]}'
	FORMAT_RANGE='{$3=pr; $4=ni; $5=virt; $6=res; $7="-1"; $8=state; $9=pctCPU; $10="-1"; $11=cpuTIME; $12=command}'
	FORMAT="$FORMAT_DOMAIN $SPECIFY_STATES_MAP $MAP_STATE $FORMAT_RANGE"
elif [ "x$KERNEL" = "xDarwin" ] ; then
	if $OSX_GE_SNOW_LEOPARD; then
		CMD="eval top -F -l 2 -ocpu -Otime -stats pid,username,vsize,rsize,rshrd,cpu,time,command"
		FORMAT='{gsub("[+-] ", " "); virt=$3; res=$4; shr=$5; pctCPU=$6; cpuTIME=$7; command=$8; $3="-1"; $4="-1"; $5=virt; $6=res; $7=shr; $8="-1"; $9=pctCPU; $10="-1"; $11=cpuTIME; $12=command}'
	else
		CMD="eval top -F -l 2 -ocpu -Otime -t -R -p '^aaaaa ^nnnnnnnnnnnnnnnnnn ^lllll ^jjjjj ^ccccc ^ddddd ^bbbbbbbbbbbbbbbbbbbbbbbbbbbbb'"
		FORMAT='{                    virt=$3; res=$4;         pctCPU=$5; cpuTIME=$6; command=$7; $3="-1"; $4="-1"; $5=virt; $6=res; $7="-1"; $8="-1"; $9=pctCPU; $10="-1"; $11=cpuTIME; $12=command}'
	fi
	HEADERIZE="BEGIN {print \"$HEADER\"}"
	FILTER='/ %CPU / {reportOrd++; next} {if ((reportOrd < 2) || !length) next}'
elif [ "x$KERNEL" = "xFreeBSD" ] ; then
	CMD='top -Sb 999'
	HEADERIZE="BEGIN {print \"$HEADER\"}"
	FILTER='(NR<=8) {next} /^$/ {next}'
	FORMAT_DOMAIN='{pr=$4; ni=$5; virt=$6; res=$7; stateRaw=$8; cpuTIME=$10; pctCPU=0+$11; command=$12}'
	SPECIFY_STATES_MAP='BEGIN {map["SLEEP"]="-1"; map["STOP"]="-1"; map["ZOMB"]="-1"; map["WAIT"]="-1"; map["LOCK"]="-1"; map["START"]="-1"; map["RUN"]="-1"; map["CPU"]="-1"}'
	MAP_STATE='{sub("[0-9]+$", "", stateRaw); state=map[stateRaw]; state=state ? state : "?"}'
	FORMAT_RANGE='{$3=pr; $4=ni; $5=virt; $6=res; $7="-1"; $8=state; $9=pctCPU; $10="-1"; $11=cpuTIME; $12=command}'
	FORMAT="$FORMAT_DOMAIN $SPECIFY_STATES_MAP $MAP_STATE $FORMAT_RANGE"
fi

assertHaveCommand $CMD
$CMD | tee $TEE_DEST | $AWK "$HEADERIZE $FILTER $FORMAT $PRINTF"  header="$HEADER"
echo "Cmd = [$CMD];  | $AWK '$HEADERIZE $FILTER $FORMAT $PRINTF' header=\"$HEADER\"" >> $TEE_DEST
