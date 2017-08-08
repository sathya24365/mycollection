
	# CONN		1200 75
	# DISCONN	1200 75
	# SEARCH	550	700
	# ABORT		400	700
	
	
	
	# CONN SEARCH ABORT DISCONN
	TA1 () 
	{
		i=1
		while [ $i -le 5 ]
		do
			`input tap 1200 75`
			`input tap 550 700`
			`input tap 400 700`
			`input tap 1200 75`
			echo i is $i
			i=`busybox expr $i + 1`
			sleep 1
		done  
	}
	
	# SEARCH ABORT
	TA2 () 
	{
		i=1
		while [ $i -le 5 ]
		do
			`input tap 550 700`
			`input tap 400 700`
			echo i is $i
			i=`busybox expr $i + 1`
			sleep 1
		done  
	}



while [ 1 ]
do
	ch="1 2"
	for ch in $ch
	do	
		case "$ch" in
			1) echo "TA 1 is running" 
					TA1
			;;		  
			2) echo "TA 2 is running" 
					TA2
			;;
		esac	
	done	
done	
