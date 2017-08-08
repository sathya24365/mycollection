	# PLAY				330	150
	# STOP				235	150				
	# PAUSE				100	150
	# NEXT_TR			430	150
	# PREV_TR			550	150

	# PLAY STOP
	TA1 () {
		i=1
		while [ $i -le 5 ]
		do
			`input tap 330 150`
			sleep 2
			`input tap 235 150`
			echo i is $i
			i=`busybox expr $i + 1`
			sleep 1
		done	
	}
	
	# PLAY PAUSE
	TA2 () 
	{
		i=1
		while [ $i -le 5 ]
		do
			`input tap 330 150`
			sleep 1
			`input tap 100 150`
			echo i is $i
			i=`busybox expr $i + 1`
			sleep 1
		done  
	}
	
	# PLAY NEXT_TR PREV_TR 
	TA3 () 
	{
		i=1
		`input tap 330 150`
		while [ $i -le 5 ]
		do
			`input tap 430 150`
			sleep 1
			`input tap 550 150`
			
			echo i is $i
			i=`busybox expr $i + 1`
			sleep 1
		done  
	}
	
	# PLAY NEXT_TR PREV_TR PAUSE STOP
	TA4 () 
	{
		i=1
		while [ $i -le 5 ]
		do
			`input tap 330 150`
			sleep 1
			`input tap 430 150`
			sleep 1
			`input tap 550 150`
			sleep 1
			`input tap 100 150`
			sleep 1
			`input tap 235 150`
			echo i is $i
			i=`busybox expr $i + 1`
			sleep 1
		done  
	}



while [ 1 ]
do
	ch="1 2 3 4"
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

