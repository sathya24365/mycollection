launch()
{

	mkdir -p /sdcard/logcat/Log/
	rm -r /sdcard/logcat/*.*
	`logcat -v threadtime >> /sdcard/logcat/logcat.txt&`

}

while [ 1 ]
do
	hrs=$(date +%H)
	min=$(date +%M)
	sec=$(date +%S)

	y=$(date +%Y)
	m=$(date +%m)
	d=$(date +%d)

	
	t=`busybox expr 60 \* $min`
	t=`busybox expr 3600 - $t`
	
	`busybox killall logcat`

	launch
	echo $t
	sleep "$t"
	mv -f /sdcard/logcat/logcat.txt /sdcard/logcat/Log/logcat_$m-$d-$y-$hrs.txt	
	
done
exit 0
	