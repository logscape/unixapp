#!/bin/sh


 pids=`ps -ef | awk '{print $2}' | grep -v PID`

 echo $pids | xargs pfiles | grep mode


