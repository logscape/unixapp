#!/bin/bash

# Ensure the PATH is sane on all recognised systems -
export PATH=/bin:/usr/bin:/usr/local/bin
NA='n/a' # this is stub for the fields which are not available on the platform

# 1. extract the system data using iostat - OS specific -
# (collect r/w speeds in KB/sec and convert them to MB/sec later
CMD_NETSTAT_RHAT="sar -n DEV 1 2"
CMD_NETSTAT_UBNT="sar -n DEV 1 2"
CMD_NETSTAT_SOLS="perl ./nicstat.pl 1 1"
CMD_NETSTAT_OSX="sar -n DEV 1 2"

# 2. select only the needed columns - OS specific
# Output format should have the following fields:
# device,rxpck/s,txpck/s,rxkB/s,txkB/s,rxcmp/s,txcmp/s,rxmcst/s
CMD_FILTER_RHAT="|egrep -i Aver |egrep -vi 'iface| lo ' \
|awk '{printf \"%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n\",\$2,\$3,\$4,\$5,\$6,\$7,\$8,\$9}'"
CMD_FILTER_UBNT="|egrep -i Aver |egrep -vi 'iface| lo ' \
|awk '{printf \"%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n\",\$2,\$3,\$4,\$5,\$6,\$7,\$8,\$9}'"
CMD_FILTER_SOLS="|egrep -v 'Time| lo' \
|awk '{printf \"%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n\",\$2,\$5,\$6,\$3,\$4,\"$NA\",\"$NA\",\"$NA\"}'"    
CMD_FILTER_OSX="|egrep -i Aver |egrep -vi 'iface|lo[0-9] ' \
|awk '{printf \"%s\t%s\t%s\t%.1f\t%.1f\t%s\t%s\t%s\n\",\$2,\$3,\$5,\$4/1024,\$6/1024,\"$NA\",\"$NA\",\"$NA\"}'"    

# Find out which OS we are on. (Have to use egrep, or it won't work on Solaris) -
REL="$(uname -s) $(egrep 'Ubuntu|Hat|Solaris' /etc/*rele* 2>/dev/null |head -1)"
case "$REL" in
*Ubuntu*)
	CMD="$CMD_NETSTAT_UBNT $CMD_FILTER_UBNT"
	;;
*Hat*)
	CMD="$CMD_NETSTAT_RHAT $CMD_FILTER_RHAT"
	;;
*Solaris*)
	CMD="$CMD_NETSTAT_SOLS $CMD_FILTER_SOLS"
	;;
*Darwin*)
	CMD="$CMD_NETSTAT_OSX $CMD_FILTER_OSX"
	;;
*)
	# Unknown OS
	CMD="echo"
	;;
esac

eval $CMD
exit $?
