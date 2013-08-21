#!/bin/sh
# 
. `dirname $0`/common.sh

HEADER='Filesystem                                          Type              Size        Used       Avail      UsePct    MountedOn'
HEADERIZE='{if (NR==1) {$0 = header}}'
PRINTF='{if (NR==1) {} else {printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n", $1, $2, $3, $4, $5, $6, $7}}'

if [ "x$KERNEL" = "xLinux" ] ; then
	assertHaveCommand df
	CMD='df -TPhl'
	FILTER_POST='($2 ~ /^(tmpfs)$/) {next}'
elif [ "x$KERNEL" = "xSunOS" ] ; then
	assertHaveCommandGivenPath /usr/bin/df
	if $SOLARIS_8; then
		CMD='eval /usr/bin/df -nl ; /usr/bin/df -kl'
		NORMALIZE='function fromKB(KB) {MB = KB/1024; if (MB<1024) return MB "M"; GB = MB/1024; return GB "G"} {$3=fromKB($3); $4=fromKB($4); $5=fromKB($5)}'
	else
		CMD='eval /usr/bin/df -nl ; /usr/bin/df -hl'
	fi
	FILTER_PRE='/libc_psr/ {next}'
	MAP_FS_TO_TYPE='/: / {fsTypes[$1] = $3; next}'
	HEADERIZE='/^Filesystem/ {print header; next}'
	FORMAT='{size=$2; used=$3; avail=$4; usePct=$5; mountedOn=$6; $2=fsTypes[mountedOn]; $3=size; $4=used; $5=avail; $6=usePct; $7=mountedOn}'
	FILTER_POST='($2 ~ /^(devfs|ctfs|proc|mntfs|objfs|lofs|fd|tmpfs)$/) {next} ($1 == "/proc") {next}'
elif [ "x$KERNEL" = "xDarwin" ] ; then
	assertHaveCommand mount
	assertHaveCommand df
	CMD='eval mount -t nocddafs,autofs,devfs,fdesc,nfs; df -h -T nocddafs,autofs,devfs,fdesc,nfs'
	MAP_FS_TO_TYPE='/ on / {fs=$1; sub("^.*\134(", "", $0); sub(",.*$", "", $0); fsTypes[fs] = $0; next}'
	HEADERIZE='/^Filesystem/ {print header; next}'
	FORMAT='{size=$2; used=$3; avail=$4; usePct=$5; mountedOn=$6; for(i=7; i<=NF; i++) mountedOn = mountedOn " " $i; $2=fsTypes[$1]; $3=size; $4=used; $5=avail; $6=usePct; $7=mountedOn}'
	NORMALIZE='{sub("^/dev/", "", $1); sub("s[0-9]+$", "", $1)}'
elif [ "x$KERNEL" = "xFreeBSD" ] ; then
	assertHaveCommand mount
	assertHaveCommand df
	CMD='eval mount -t nodevfs,nonfs,noswap,nocd9660; df -h -t nodevfs,nonfs,noswap,nocd9660'
	MAP_FS_TO_TYPE='/ on / {fs=$1; sub("^.*\134(", "", $0); sub(",.*$", "", $0); fsTypes[fs] = $0; next}'
	HEADERIZE='/^Filesystem/ {print header; next}'
	FORMAT='{size=$2; used=$3; avail=$4; usePct=$5; mountedOn=$6; $2=fsTypes[$1]; $3=size; $4=used; $5=avail; $6=usePct; $7=mountedOn}'
fi

#$CMD | tee $TEE_DEST | $AWK "$HEADERIZE $FILTER_PRE $MAP_FS_TO_TYPE $FORMAT $FILTER_POST $NORMALIZE $PRINTF"  header="$HEADER"
#echo "Cmd = [$CMD];  | $AWK '$HEADERIZE $FILTER_PRE $MAP_FS_TO_TYPE $FORMAT $FILTER_POST $NORMALIZE $PRINTF' header=\"$HEADER\"" >> $TEE_DEST


$CMD | tee $TEE_DEST | $AWK "$FILTER_PRE $MAP_FS_TO_TYPE $FORMAT $FILTER_POST $NORMALIZE $PRINTF"
echo "Cmd = [$CMD];  | $AWK '$FILTER_PRE $MAP_FS_TO_TYPE $FORMAT $FILTER_POST $NORMALIZE $PRINTF'" >> $TEE_DEST
