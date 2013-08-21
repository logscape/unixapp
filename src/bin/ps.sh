#!/bin/sh
# 
# 

. `dirname $0`/common.sh

HEADER='USER	PID	PSR	pctCPU	CPUTIME	pctMEM	RSZ_KB	VSZ_KB	TTY	S	ELAPSED	COMMAND	ARGS'
FORMAT='{sub("^_", "", $1); if (NF>12) {args=$13; for (j=14; j<=NF; j++) args = args "_" $j} else args="<noArgs>"; sub("^[^\134[: -]*/", "", $12)}'
NORMALIZE='(NR>1) {if ($4<0 || $4>100) $4=0; if ($6<0 || $6>100) $6=0}'
## PID $3  PSR $4  CPUTIME $6  PCTMEM $7 
PRINTF='{if (NR == 1) {} else {if($6 > 0 && $7 > 0.1 ){ printf "%.14s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%.7s\t%.1s\t%s\t%.18s\t%s\n", $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, args}}}'

HEADERIZE='{NR == 1 && $0 = header}'
CMD='ps auxww'

if [ "x$KERNEL" = "xLinux" ] ; then
	assertHaveCommand ps
	CMD='ps -wweo uname,pid,psr,pcpu,cputime,pmem,rsz,vsz,tty,s,etime,args'
elif [ "x$KERNEL" = "xSunOS" ] ; then
	assertHaveCommandGivenPath /usr/bin/ps
	CMD='/usr/bin/ps -eo user,pid,psr,pcpu,time,pmem,rss,vsz,tty,s,etime,args'
elif [ "x$KERNEL" = "xDarwin" ] ; then
	assertHaveCommand ps
	CMD='ps axo ruser,pid,pcpu,cputime,pmem,rss,vsz,tty,state,etime,command'
	FILL_BLANKS='{if (NR>1) {for (i=NF; i>2; i--) $(i+1) = $i; $3 = "0"}}'
elif [ "x$KERNEL" = "xFreeBSD" ] ; then
	assertHaveCommand ps
	CMD='ps axo ruser,pid,pcpu,cputime,pmem,rss,vsz,tty,state,etime,command'
	FILL_BLANKS='{if (NR>1) {for (i=NF; i>2; i--) $(i+1) = $i; $3 = "0"}}'
fi

#$CMD | tee $TEE_DEST | $AWK "$HEADERIZE $FILL_BLANKS $FORMAT $NORMALIZE $PRINTF"  header="$HEADER"
#echo "Cmd = [$CMD];  | $AWK '$HEADERIZE $FILL_BLANKS $FORMAT $NORMALIZE $PRINTF' header=\"$HEADER\"" >> $TEE_DEST

$CMD | tee $TEE_DEST | $AWK "$HEADERIZE $FILL_BLANKS $FORMAT $NORMALIZE $PRINTF"
echo "Cmd = [$CMD];  | $AWK '$HEADERIZE $FILL_BLANKS $FORMAT $NORMALIZE $PRINTF'" >> $TEE_DEST
