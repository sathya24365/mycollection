while [ 1 ]
do
	if [ -d /data/tombstones ] || [ -d /data/anr ] ; then
		
		echo Tombstone Dir found
		for i in 00 01 02 03 04 05 06 07 08 09
		do
			hrs=$(date +%H)
			min=$(date +%M)
			sec=$(date +%S)
			
			y=$(date +%Y)
			m=$(date +%m)
			d=$(date +%d)
			
			if [ -f /data/tombstones/tombstone_$i ] ; then				
				echo Tombstone_$i found
				mkdir /data/tombstones/Log
				mv -f /data/tombstones/tombstone_$i /data/tombstones/Log/tombstone_$m-$d-$y-$hrs-$min-$sec
			else 
				echo tombstone_$i not found
			fi		
		done

		if [ -f /data/anr/traces.txt ] ; then

			hrs=$(date +%H)
			min=$(date +%M)
			sec=$(date +%S)
			
			y=$(date +%Y)
			m=$(date +%m)
			d=$(date +%d)

			echo Traces found

			mkdir -p /data/anr/Log

			mv -f /data/anr/traces.txt /data/anr/Log/traces_$m-$d-$y-$hrs-$min-$sec.txt
			`bugreport > /data/anr/Log/bugreport_$m-$d-$y-$hrs-$min-$sec.txt&`
			
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