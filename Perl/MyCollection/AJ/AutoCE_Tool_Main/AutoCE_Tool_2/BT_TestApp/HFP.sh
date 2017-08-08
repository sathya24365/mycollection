	# AUDIO				245	155
	# CONN				85	155				
	# ACCEPT			600	580
	# REJECT			600	650
	# HOLD AND ACCEPT
	# ACCEPT HELD
	#					875	580
	# TERMINATE			875	650
	# HOLD				1150 650


	# AUDIO
	TA1 () {
		i=1
		while [ $i -le 5 ]
		do
			`input tap 245 155`
			
			echo i is $i
			i=`busybox expr $i + 1`
			sleep 1
		done	
	}
	
	# HOLD AND ACCEPT HELD
	TA2 () 
	{
		i=1
		while [ $i -le 5 ]
		do
			`input tap 1150 650`
			sleep 1
			`input tap 875 580`
			echo i is $i
			i=`busybox expr $i + 1`
			sleep 1
		done  
	}
	
	# CONN 
	TA3 () 
	{
		i=1
		while [ $i -le 5 ]
		do
			`input tap 85 155`
			echo i is $i
			i=`busybox expr $i + 1`
			sleep 1
		done  
	}
	
	# CONN AUDIO HOLD AND HELD
	TA4 () 
	{
		i=1
		while [ $i -le 5 ]
		do
			`input tap 85 155`
			echo i is $i
			i=`busybox expr $i + 1`
			sleep 1
		done  
	}



while [ 1 ]
do
	ch="1 2 3"
	for ch in $ch
	do	
		case "$ch" in
			1) echo "TA 1 is running" 
					TA1
			;;		  
			2) echo "TA 2 is running" 
					TA2
			;;
			3) echo "TA 3 is running" 
					TA3
			;;
			4) echo "TA 4 is running" 
					TA4
			;;
		esac	
	done	
done	

