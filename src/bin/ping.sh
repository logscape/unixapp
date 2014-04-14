#!/bin/sh

echo $* >> args.list 
for var in $(echo $*);do 
	case "$var" in 
		*=*)
			eval $var
		;;
	esac 
	#fi 
done

hosts=`echo $ping | cut -f 2 -d \=`
for range in $( echo $hosts | sed -e 's/,/ /' );do 
	echo $range | cut -f 2 -d \=
	ping_start=`echo $range | cut -f 1 -d \-`
	start=`echo $ping_start |  cut -f 4 -d .`
	stem=`echo $ping_start |  cut -f 1,2,3 -d .`
	end=`echo $range | cut -f 2 -d \-` 
	
	#echo details: $ping_start ,$stem ,  $start ,  $end
	for x in `seq $start $end`;do 
		ping $stem.$x -s 56 -c 3 -W 5  | grep from | grep -v Host  |  awk '{print $4"\t"$7}' | sed -e 's/time=//' | sed -e 's/\://'   & 
		if [ 0 -eq $(echo 50 % $x  | bc)  ];then sleep 3s ; echo moo ;fi	
		#echo details: $ping_start ,$stem ,  $start ,  $end
	done
done 
#for x in `seq 150 170`;do ping 10.28.1.$x -s 56 -c 3 -W 5 | grep from | grep -v Host  |  awk '{print $4"\t"$7}' | sed -e 's/time=//' | sed -e 's/\://';done
sleep 5s 
