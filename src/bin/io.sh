#!/bin/bash

# Ensure the PATH is sane on all recognised systems -
export PATH=/bin:/usr/bin:/usr/local/bin:/usr/sbin:/sbin

# 1. extract the system data using iostat - OS specific -
# (collect r/w speeds in KB/sec and convert them to MB/sec later
CMD_IOSTAT_RHAT="iostat -zxk 1 2"
CMD_IOSTAT_UBNT="iostat -zxk 1 2"
CMD_IOSTAT_SOLS="iostat -zx 1 2"
CMD_IOSTAT_OSX="iostat -dK -n32 1 2"

# processing commands:
# Note that iostat returns in the 1st output the values averages since the system start -
# not what we want here...
# 2. delete lines up to the 2nd 'Device:...' inclusive, also empty files. 
# Works on Solaris, RHEL and Ubuntu. Note the 2 interval delete commands, which correspond
# to the 2 iosata calls above
CMD_SLICE_HEAD_OFF="|sed -e '1,/[dD]evice/d' |sed -e '1,/^[dD]evice/d;/^$/d' |sort"
# 3. select only the needed columns - OS specific
# Output format should have 12 fileds, TAB-separated:
# device,rrqm,wrqm,readsPerSec,writesPerSec,readMBSec,writeMBSec,sectorsPerRequest,avgQueueLength,await,svctm,util
NA='n/a' # this is stub for the fields which are not available on the platform
CMD_FILTER_RHAT="|awk '{printf \"%s\t%s\t%s\t%s\t%s\t%.4f\t%.4f\t%s\t%s\t%s\t%s\t%s\n\", \
\$1,\$2,    \$3,    \$4,\$5,\$6/1024,\$7/1024,\"$NA\",\$9,\$10,\"$NA\",\$12}'"
CMD_FILTER_UBNT="|awk '{printf \"%s\t%s\t%s\t%s\t%s\t%.4f\t%.4f\t%s\t%s\t%s\t%s\t%s\n\", \
\$1,\$2,    \$3,    \$4,\$5,\$6/1024,\$7/1024,\"$NA\",\$9,\$10,\"$NA\",\$12}'"
CMD_FILTER_SOLS="|awk '{printf \"%s\t%s\t%s\t%s\t%s\t%.4f\t%.4f\t%s\t%s\t%s\t%s\t%s\n\", \
\$1,\"$NA\",\"$NA\",\$2,\$3,\$4/1024,\$5/1024,\"$NA\",\$6, \$8,\"$NA\",\$10}'"    
CMD_FILTER_OSX="|awk '/disk[0-9].* / {nf=NF; next} /.*[a-zA-Z].*/ {next;} {if (NR>3) {for(i=0;i<nf;i++) {printf \"%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n\", \
\"disk\" i,\"$NA\",\"$NA\",\$(i+2),\"$NA\",\$(i+3),\"$NA\",\$(i+1),\"$NA\",\"$NA\",\"$NA\",\"$NA\"}}}'"


# Find out which OS we are on. (Have to use egrep, or it won't work on Solaris) -
REL="$(uname -s) $(egrep 'Ubuntu|Hat|Solaris' /etc/*rele* 2>/dev/null |head -1)"
case "$REL" in
*Ubuntu*)
	CMD="$CMD_IOSTAT_UBNT $CMD_SLICE_HEAD_OFF $CMD_FILTER_UBNT"
	;;
*Hat*)
	CMD="$CMD_IOSTAT_RHAT $CMD_SLICE_HEAD_OFF $CMD_FILTER_RHAT"
	;;
*Solaris*)
	CMD="$CMD_IOSTAT_SOLS $CMD_SLICE_HEAD_OFF $CMD_FILTER_SOLS"
	;;
*Darwin*)
	CMD="$CMD_IOSTAT_OSX $CMD_FILTER_OSX"
	;;
*)
	# Unknown OS , defaults to Ubuntu 
	CMD="$CMD_IOSTAT_UBNT $CMD_SLICE_HEAD_OFF $CMD_FILTER_UBNT"
	;;
esac

eval $CMD
exit $?
