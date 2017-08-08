up_time()
{

	check=`uptime | busybox cut -c 13-16`
	
	if [ "$check" == "days" ] ; then
	
		hrs=`uptime | busybox cut -c 19-20`
		min=`uptime | busybox cut -c 22-23`
		sec=`uptime | busybox cut -c 25-26`
		day=`uptime | busybox cut -c 10-11`
		
	else
	
		hrs=`uptime | busybox cut -c 10-11`
		min=`uptime | busybox cut -c 13-14`
		sec=`uptime | busybox cut -c 16-17`	
		day=0

	fi
	
	echo Day:$day
	echo Hrs:$hrs
	echo Min:$min
	echo Sec:$sec

}

while [ 1 ]
do
	if [ -d /data/tombstones ] || [ -d /data/anr ] ; then
		
		echo Tombstone Dir found
		for i in 00 01 02 03 04 05 06 07 08 09
		do
			ext=$(date +%Y_%m_%d_%H_%M_%S)
			if [ -f /data/tombstones/tombstone_$i ] ; then				
				echo Tombstone_$i found
				mv -f /data/tombstones/tombstone_$i /data/tombstones/tombstone_$ext				
			else 
				echo tombstone_$i not found
			fi		
		done

		if [ -f /data/anr/traces.txt ] ; then
			ext=$(date +%H_%M_%S)
			h=$(date +%H)
			y=$(date +%Y)
			m=$(date +%m)
			d=$(date +%d)
			up_time
			echo Traces found
			mkdir /data/anr/$m-$d-$y/$h/ANR_$day_$hrs_$min_$sec
			# logcat -d > /data/anr/log_$ext/logcat.txt
			mv -f /data/anr/traces.txt /data/anr/$m-$d-$y/$h/ANR_$day_$hrs_$min_$sec
			bugreport > /data/anr/$m-$d-$y/$h/ANR_$day_$hrs_$min_$sec/bugreport.txt
			
		else 
			echo Traces not found
		fi

	else 
		echo "Tombstones/ANR not found"
	fi
	echo sleep 2
	sleep 2
done
exit 0