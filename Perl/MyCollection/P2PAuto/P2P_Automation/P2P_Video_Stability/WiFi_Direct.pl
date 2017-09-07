require devices;
$|       = 1;
$device1 = $ARGV[0];
$device2 = $ARGV[1];

devices::killProcess("checkP2P_$device1");

%deviceHash1 = devices::genHash($device1);
%deviceHash2 = devices::genHash($device2);

devices::setup($device1);
devices::setup($device2);

devices::openWifiDirect($device1);
devices::openWifiDirect($device2);

#Get P2P Device ID of DUTs
$P2P_Device1 = `adb -s $device1 shell getprop P2PdeviceID`;
$P2P_Device2 = `adb -s $device2 shell getprop P2PdeviceID`;

#devices::searchDevices($device1);
#devices::searchDevices($device2);

devices::sendInvite( $device2, $P2P_Device1 );

devices::acceptInvite($device1);
devices::acceptInvite($device2);

devices::isConnected($device1);

my $temp=`adb -s $device1 shell ls /sdcard/17Again.mp4`;
if($temp=~/No such file or directory/)
{
system("adb -s $device1 push 17Again.mp4 /sdcard/");
}
else
{
print "\nVideo File already exists in device: $device1\n";
}


$temp=`adb -s $device2 shell ls /sdcard/17Again.mp4`;
if($temp=~/No such file or directory/)
{
system("adb -s $device2 push 17Again.mp4 /sdcard/");
}
else
{
print "\nVideo File already exists in device: $device2\n";
}


sleep 3;

my $pid = fork();
if ( not defined $pid ) {
	die 'resources not available';
} elsif ( $pid == 0 ) {

	#CHILD
	#system("start \"wifiDirect\" /MIN cmd.exe /k sleep 5" );
	system( 1, "start \"checkP2P_$device1\" perl.exe checkP2P.pl $device1 $device2" );
	exit(0);
} else {

	# PARENT -- Do nothing
	$ip1 = devices::startServer($device1);
	$ip2 = devices::startServer($device2);

	if ( $ip1 == 0 )
	{
		print "\n\tUnable to establish successfull Wifi-Direct Connection..\n";
	}
	if ( $ip2 == 0 )
	{
		print "\n\tUnable to establish successfull Wifi-Direct Connection..\n";
	}

	#system( 1, "perl checkP2P.pl" );

	devices::startLogging( \%deviceHash1 );
	devices::startLogging( \%deviceHash2 );

	devices::videoStability( \%deviceHash1, $ip2 );
	sleep 15;
	devices::videoStability( \%deviceHash2, $ip1 );
}

