package devices;

use Win32;
use Win32::Process;

$deviceCheck = 1;

sub detect {

	@devices = `adb devices`;

	#print "Devices: @devices";
	print("\nDetecting the devices connected to this PC...\n");
	foreach (@devices) {

		#print "line $i: ".$_;
		if (/List of devices attached/) {

		}
		else {
			if ( (/(\w+)\s+(device)/) ) {
				push( @device_id, $1 );
			}
		}

	}
	if ( $deviceCheck == 1 )
	{
		if ( $#device_id < 1 ) {
			print "\n@devices";
			print "FATAL ERROR::Unable to detect 2 devices Connected to the PC, please check device physical connection/state..!!\n\n";
			print "\n\nEnter any key to Continue..";
			<>;
			exit(0);
		}
	}
	sleep 1;
}

sub display {
	print "\n\tDevices Connected to this PC: \n";
	$index = 1;
	foreach (@device_id) {
		print "\tDevice $index: $_\n";
		$index++;
	}
}

sub genHash
{
	my $id = $_[0];

	print "\nIn genHash() $id\n";

	%device = ( "adb" => "adb_$id",
		"kernel" => "kernel_$id",
		"video"  => "video_$id" );

	while ( ( $key, $value ) = each(%device) ) {
		print $key. ", " . $value . "\n";
	}
	print "\n";
	return %device;

}

#################################################################
#This Subroutine takes adb device id as parameter and
#
##################################################################
sub setup {

	#$id is the adb device id of device being setup
	my $id = $_[0];
	print("\nSetting Device: $id for test..\n");

	print("\n\tRooting and Remounting the $id device..\n\n");
	system("adb -s $id root");

	sleep 5;
	system("adb -s $id remount");
	sleep 2;

	#install IsScreenUp apk
	print("\n\nSetting screen timeout to 30 mins..\n");
	system("adb -s $id install -rf IsScreenUp.apk");

	#Open IsScreenUp apk
	system("adb -s $id shell am start -n com.qualcomm.isscreenup/.MainActivity");

}

sub startServer {
	my $id = $_[0];

	#install IsScreenUp apk
	print("\n\nInstalling KWS Server on device: $id..\n");
	system("adb -s $id install -rf kws_server.apk");
	sleep 2;
	print("\n\tStarting KWS Server on device: $id..");
	system("adb -s $id shell am start -n org.xeustechnologies.android.kws/.ui.KwsActivity");
	sleep 2;
	system("pwd");
	system("adb -s $id shell uiautomator runtest UIAutomator_4.4.2.jar -c com.qualcomm.httpserver.startServer | tee ./Logs/ServerLog_$id.log");

	#system("adb -s $id pull /sdcard/ServerLog_$id.log /Logs/");
	$IP = parseIP($id);
	print "\nIP Fetched: $IP";
	return $IP;
}

sub parseIP {
	my $id = $_[0];
	open SLOG, "./Logs/ServerLog_$id.log" or die $!;
	@log = <SLOG>;
	close SLOG;

	foreach (@log)
	{
		if ( $_ =~ /Host {([\d]{1,3}\.[\d]{1,3}\.[\d]{1,3}\.[\d]{1,3})}/ )
		{
			return $1;
			$foundIP = 1;
		}
	}
	if ( $foundIP == 0 )
	{
		print "\n\tUnable to get a valid IP, check if WiFi Direct connection is proper !!";
		return 0;
	}
}

sub EnableWiFi {
	my $id = $_[0];
	print "\n\tEnabling WiFi on device..\n";
	system("adb -s $id shell svc wifi enable");
}

sub DisableWiFi {
	my $id = $_[0];
	print "\n\tDisabling WiFi on device..\n";
	system("adb -s $id shell svc wifi disable");
}

sub clearConfig {

	my $id = $_[0];
	system("adb -s $id pull /data/misc/wifi/p2p_supplicant.conf ./Logs/p2p_supplicant_$id.conf");
	print("\n\Clearing REMEMBERED GROUPS from P2P config Files..\n");
	sleep(2);
	open FILE, "./Logs/p2p_supplicant_$id.conf" or warn $!;
	open NEW,  ">./Logs/p2p_supplicant.conf"    or die $!;
	@conf = <FILE>;
	close(FILE);
	our @newConf, $i;

	foreach (@conf) {
		if ( $_ =~ "network={" ) {
			print "\nSucceeded resetting P2Pconfig File..\n";
			last;
		}
		$newConf[i] = $_;
		print NEW $newConf[i];
		$i++;
	}

	foreach (@newConf) {
		print $_;
	}

	close(NEW);
	system("adb -s $id push ./Logs/p2p_supplicant.conf /data/misc/wifi/p2p_supplicant.conf");
}

sub openWifiDirect {
	my $id = $_[0];

	#Initiate a Home Keyevent
	system("adb -s $id shell input keyevent 3");

	print("\n\tOpening WiFi Direct on device: $id..\n");

	#Open Device Settings
	system("adb -s $id shell am start -n com.android.settings/.Settings");

	#Run OpenWifiDirect UIAS
	system("adb -s $id push UIAutomator_4.4.2.jar /data/local/tmp/");
	system("adb -s $id shell uiautomator runtest UIAutomator_4.4.2.jar -c com.qualcomm.wifidirect.OpenWifiDirect");
}

sub acceptInvite {
	my $id = $_[0];
	system("adb -s $id shell uiautomator runtest UIAutomator_4.4.2.jar -c com.qualcomm.wifidirect.acceptInvite");
}

sub isConnected {
	my $id = $_[0];
	system("adb -s $id shell uiautomator runtest UIAutomator_4.4.2.jar -c com.qualcomm.wifidirect.isConnected");
}

#adb shell setprop PeerID Android_7212

sub searchDevices {
	my $id = $_[0];
	print "\n\tSearching for Peer devices on $id..\n";
	system("adb -s $id shell uiautomator runtest UIAutomator_4.4.2.jar -c com.qualcomm.wifidirect.searchDevices");
}

sub sendInvite {
	my $id     = $_[0];
	my $peerID = $_[1];
	print "\n\tSending Peer Invitation to device: $id..\n";
	system("adb -s $id shell setprop PeerID $peerID");
	system("adb -s $id shell uiautomator runtest UIAutomator_4.4.2.jar -c com.qualcomm.wifidirect.sendInvite");
}

sub videoStability {

	my $id = $_[0];
	my $ip = $_[1];
	$| = 1;

	print "Starting Logs on device: $id ... \n";

	Win32::Process::Create( $p1, 'c:/perl/bin/perl.exe', "perl adbLogs.pl $id", 1, CREATE_NEW_CONSOLE, '.', ) or die Win32::FormatMessage( Win32::GetLastError() );
	sleep 2;
	Win32::Process::Create( $p2, 'c:/perl/bin/perl.exe', "perl dmsgLogs.pl $id", 1, CREATE_NEW_CONSOLE, '.', ) or die Win32::FormatMessage( Win32::GetLastError() );

	system("adb -s $id push 17Again.mp4 /sdcard/");
	sleep 3;
	Win32::Process::Create( $p3, 'c:/perl/bin/perl.exe', "perl videoStability.pl $id $ip", 1, CREATE_NEW_CONSOLE, '.', ) or die Win32::FormatMessage( Win32::GetLastError() );

	#system("start cmd.exe /k $cmd")
}

sub checkDisconnect
{
	$id  = $_[0];
	@out = `adb -s $id shell ping -c 1 192.168.49.1`;

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
		return 0;
	}
	else
	{
		return 1;
	}
}

sub startLogging {

	my $id        = $_[0];
	my $deviceRef = $_[1];
	my %device    = %{$deviceRef};

	$| = 1;
	
	print "Starting Logs on device: $id ... \n";

#Win32::Process::Create( $p1, 'c:/perl/bin/perl.exe', "perl adbLogs.pl $id", 1, CREATE_NEW_CONSOLE, '.', ) or die Win32::FormatMessage( Win32::GetLastError() );
	startProcess( "$device{'adb'}", "perl adbLogs.pl $id" );
	sleep 2;

#Win32::Process::Create( $p2, 'c:/perl/bin/perl.exe', "perl dmsgLogs.pl $id", 1, CREATE_NEW_CONSOLE, '.', ) or die Win32::FormatMessage( Win32::GetLastError() );
	startProcess( "$device{'kernel'}", "perl dmsgLogs.pl $id" );
}

sub startProcess
{
	my $title = $_[0];
	my $cmd   = $_[1];
	system("start \"$title\" /MIN cmd.exe /k $cmd");
}

sub killProcess
{
	$title = $_[0];
	system("taskkill /FI \"WINDOWTITLE eq $title*\"");
}

1;

