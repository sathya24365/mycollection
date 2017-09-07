$id = $ARGV[0];
$IP = $ARGV[1];

$i = 1;
$j = 1;
while ( $i <= 3000 )
{
	print "Iteration No: " . $i . "\n\n";

	system("adb -s $id shell input keyevent 3");

	#	Clears data of video player
	system("adb -s $id shell pm clear com.android.gallery3d");

	#	Defaults to Stock Video Player
	print("adb -s $id shell am start -d http://$IP:8080/17Again.mp4 -n com.android.gallery3d/.app.MovieActivity");

#	print("adb -s $id shell am start -d http://$IP:8080/17again.mp4 -t video/mp4 -a android.intent.action.VIEW");
	system( "adb -s $id shell am start -d http://" . $IP . ":8080/17Again.mp4 -n com.android.gallery3d/.app.MovieActivity" );

#	system( "adb -s $id shell am start -d http://" . $IP . ":8080/17again.mp4 -t video/mp4 -a android.intent.action.VIEW" );
	sleep 50;

	$out = `tasklist /FI "IMAGENAME eq adb.exe"`;
	if ( $out =~ /No tasks are running/ )
	{
		exit(0);
	}
	else
	{
		print "\nIn else Block\n";
		sleep 1;
	}
	
	system("adb -s $id shell input keyevent 4");
	system("adb -s $id shell input keyevent 4");

	$i++;
}
