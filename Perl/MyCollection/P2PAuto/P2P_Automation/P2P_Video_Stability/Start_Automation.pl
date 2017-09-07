use devices;
devices::detect();
devices::display();
$| = 1;

print "\nPlease enter device1 id:";
$device1 = <>;
chomp($device1);

print "\nPlease enter device2 id:";
$device2 = <>;
chomp($device2);

system("mkdir Logs");

my $pid = fork();
if ( not defined $pid ) {
	die 'resources not available';
} elsif ( $pid == 0 ) {

	#CHILD
	#system("start \"wifiDirect\" /MIN cmd.exe /k sleep 5" );
	system( 1, "start \"wifiDirect_$device1\" perl.exe WiFi_Direct.pl $device1 $device2 | tee Logs/stdout.log" );
} else {

	# PARENT -- Do nothing
}
#system("perl WiFi_Direct.pl $device1 $device2 | tee Logs/stdout.log");

