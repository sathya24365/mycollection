require devices;
$|       = 1;
$device1 = $ARGV[0];
$device2 = $ARGV[1];

#Configurable (in Sec)
$delay = 15;

%deviceHash1 = devices::genHash($device1);
%deviceHash2 = devices::genHash($device2);

devices::setup($device1);
devices::setup($device2);

disconnectP2P();

devices::startLogging( $device1, \%deviceHash1 );
devices::startLogging( $device2, \%deviceHash2 );

system("del Logs\\Result.log");

for ( $i = 1 ; $i <= 3000 ; $i++ )
{
	open RLOG, ">>./Logs/Result.log" or die $!;

	$result = connectP2P();
	if ( $result == 0 )
	{

		print "\nPass\n";

		#Log Pass to RLOG
		print RLOG "\nIteration: $i: PASS\n";
	}
	else
	{
		if ( $result == 1 )
		{
			print "\nFail\n";
			print RLOG "\nIteration: $i: FAIL\n";
		}
	}
	sleep($delay);
	disconnectP2P();
	sleep($delay);
}

close RLOG;

sub connectP2P
{
	devices::clearConfig($device1);
	sleep 2;
	devices::EnableWiFi($device1);
	sleep 2;
	devices::clearConfig($device2);
	sleep 2;
	devices::EnableWiFi($device2);
	sleep 2;
	devices::openWifiDirect($device1);
	devices::openWifiDirect($device2);

	#Get P2P Device ID of DUTs
	$P2P_Device1 = `adb -s $device1 shell getprop P2PdeviceID`;
	$P2P_Device2 = `adb -s $device2 shell getprop P2PdeviceID`;

	devices::sendInvite( $device2, $P2P_Device1 );

	devices::acceptInvite($device1);
	devices::acceptInvite($device2);

	devices::isConnected($device1);

	sleep($delay);
	$res = devices::checkDisconnect($device1);

	return $res;
}

sub disconnectP2P
{
	devices::DisableWiFi($device1);
	devices::DisableWiFi($device2);
}
