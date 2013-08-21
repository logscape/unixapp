#!/bin/sh
# 

. `dirname $0`/common.sh

HEADER='USERNAME                        HOME_DIR                                                      USER_INFO'
HEADERIZE="BEGIN {print \"$HEADER\"}"

CMD='cat /etc/passwd'
AWK_IFS='-F:'

FILTER='($NF !~ /sh$/) {next}'
PRINTF='{printf "%-30.30s  %-60.60s  %s\n", $1, $6, $5}'

if [ "x$KERNEL" = "xLinux" ] ; then
	FILL_BLANKS='{$5 || $5 = "?"}'
elif [ "x$KERNEL" = "xSunOS" ] ; then
	FILL_BLANKS='{$5 || $5 = "?"}'
elif [ "x$KERNEL" = "xDarwin" ] ; then
	CMD='dscacheutil -q user'
	AWK_IFS=''
	MASSAGE='/^name: / {username = $2} /^dir: / {homeDir = $2} /^shell: / {shell = $2} /^gecos: / {userInfo = $2; for (i=3; i<=NF; i++) userInfo = userInfo " " $i} !/^gecos: / {next}'
	FILTER='{if (shell !~ /sh$/) next; if (homeDir ~ /^[0-9]+$/) next}'
	PRINTF='{printf "%-30.30s  %-60.60s  %s\n", username, length(homeDir) ? homeDir : "?", userInfo}'
elif [ "x$KERNEL" = "xFreeBSD" ] ; then
	FILL_BLANKS='{$5 || $5 = "?"}'
fi

assertHaveCommand $CMD
$CMD | tee $TEE_DEST | $AWK $AWK_IFS "$HEADERIZE $MASSAGE $FILTER $FILL_BLANKS $PRINTF"  header="$HEADER"
echo "Cmd = [$CMD];  | $AWK $AWK_IFS '$HEADERIZE $MASSAGE $FILTER $FILL_BLANKS $PRINTF' header=\"$HEADER\"" >> $TEE_DEST
