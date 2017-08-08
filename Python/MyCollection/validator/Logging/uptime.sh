up_time()
{

	check=`uptime | busybox cut -c 13-16`
	echo $check
	
	if [ "$check" == "days" ] ; then
	
		hrs=`uptime | busybox cut -c 19-20`
		min=`uptime | busybox cut -c 22-23`
		sec=`uptime | busybox cut -c 25-26`
		
	else
	
		hrs=`uptime | busybox cut -c 10-11`
		min=`uptime | busybox cut -c 13-14`
		sec=`uptime | busybox cut -c 16-17`	

	fi
	
	echo Hrs:$hrs
	echo Min:$min
	echo Sec:$sec

}



while [ 1 ]
do
	up_time
	
	sleep 2
done
exit 0
