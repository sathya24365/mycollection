launch()
{

y=$(date +%Y)
m=$(date +%m)
d=$(date +%d)
mkdir /sdcard/logcat/$m-$d-$y/
`logcat -v threadtime >> /sdcard/logcat/$m-$d-$y/logcat_$hrs.txt&`

}

while [ 1 ]
do
	hrs=$(date +%H)
	min=$(date +%M)

	
	t=`busybox expr 60 \* $min`
	t=`busybox expr 3600 - $t`
	
	`busybox killall logcat`
	launch
	echo $t
	sleep "$t"
done
exit 0
	