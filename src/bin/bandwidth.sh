#!/bin/sh

#netstat -i | grep -v Iface | grep -v lo | grep -v Ker | awk '{print $1"="($4+$8)}'
sar -n DEV  1 3 |  sed -e '/^$/d' | cut -f 2- -d " " |   grep -Ev "(IFACE|lo|Average|Linux)" 
sleep 20s
sar -n DEV  1 3 |  sed -e '/^$/d' | cut -f 2- -d " " |   grep -Ev "(IFACE|lo|Average|Linux)" 
sleep 20s
sar -n DEV  1 3 |  sed -e '/^$/d' | cut -f 2- -d " " |   grep -Ev "(IFACE|lo|Average|Linux)" 
