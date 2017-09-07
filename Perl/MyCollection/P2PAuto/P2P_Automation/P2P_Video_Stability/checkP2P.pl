use devices;
$| = 1;

$device1 = $ARGV[0];
$device2 = $ARGV[1];

%deviceHash1 = devices::genHash($device1);
%deviceHash2 = devices::genHash($device2);

while (1)
{
	checkDisconnect();
	sleep(15);
}

sub checkDisconnect
{
	@out = `adb -s $device1 shell ping -c 1 192.168.49.1`;

	#@out = `adb shell ping -c 1 127.0.0.1`;
	#print @out;
	my $disconnect = 0;
	foreach (@out) {
		if ( $_ =~ /Network is unreachable/ )
		{
			print "\nCheckingP2P::P2P Network is Disconnected..\n";
			$disconnect++;
		}
	}
	if ( $disconnect == 0 )
	{
		print "\nCheckingP2P::P2P Network is Active\n";
	}
	else {

		if ( $disconnect == 1 )
		{
			devices::killProcess("wifiDirect_$deviceHash1{'id'}");
			killRun( \%deviceHash1 );
			killRun( \%deviceHash2 );
			sleep 5;
			killRun( \%deviceHash1 );
			killRun( \%deviceHash2 );
			sleep 5;
			killRun( \%deviceHash1 );
			killRun( \%deviceHash2 );
			sleep 5;
			killRun( \%deviceHash1 );
			killRun( \%deviceHash2 );
			sleep 5;
			print "\n\nRe-initiating the tests..\n\n";

			my $pid = fork();
			if ( not defined $pid ) {
				die 'resources not available';
			} elsif ( $pid == 0 ) {

				#CHILD
				#system("start \"wifiDirect\" /MIN cmd.exe /k sleep 5" );
				system( 1, "start \"wifiDirect_$deviceHash1{'id'}\" perl.exe WiFi_Direct.pl $device1 $device2 | tee Logs/stdout.log" );
			} else {

				# PARENT -- Do nothing
			}	

			sleep 2;
			exit(0);
		}
	}
}

sub killRun {
	my $deviceRef = $_[0];
	my %device    = %{$deviceRef};
	print("\n\nKilling all processes of $device{'id'}... \n\n");
	devices::killProcess( $device{'adb'} );
	devices::killProcess( $device{'kernel'} );
	devices::killProcess( $device{'video'} );

	system("adb -s $device{'id'} shell input keyevent 3");

}
