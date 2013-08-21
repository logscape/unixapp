#!/bin/bash
OS=`uname -s`

ZEROS='0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00    0.00    0.00   0.00   0.00'
if [ "$OS" = "Linux" ];then
        LINECOUNT=`iostat -xm 1 1 | grep -iv "avg\|Device\|Linux" |  grep -v "^$\|^ "   | wc --lines `
        iostat -xm 1 3 | grep -iv "avg\|Device\|Linux" |  grep -v "^$\|^ "  | awk "{if (NR>"$LINECOUNT") { print } }" | grep -v "$ZEROS"
	sleep 20s
        iostat -xm 1 3 | grep -iv "avg\|Device\|Linux" |  grep -v "^$\|^ "  | awk "{if (NR>"$LINECOUNT") { print } }"  | grep -v "$ZEROS"
	sleep 20s
        iostat -xm 1 3 | grep -iv "avg\|Device\|Linux" |  grep -v "^$\|^ "  | awk "{if (NR>"$LINECOUNT") { print } }" | grep -v "$ZEROS" 
	sleep 20s
        iostat -xm 1 3 | grep -iv "avg\|Device\|Linux" |  grep -v "^$\|^ "  | awk "{if (NR>"$LINECOUNT") { print } }"  | grep -v "$ZEROS" 
fi

if [ "$OS" = "SunOS" ];then
        echo
        #
fi
if [ "$OS" = "Darwin" ];then
        # 
        echo
fi


