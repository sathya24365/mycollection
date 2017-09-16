use Win32::OLE;
use Win32::OLE::Variant;
# use Switch;
use Win32::Console; 
my $CONSOLE=Win32::Console->new;

my $TargetPort = ""; 	
my $Iterations = ""; 	
my $qpst = "";   		
my $port_id = ""; 		
my $prod_id = "QPSTAtmnServer.Application"; 
my $uport_id="";

my %phone_mode_list = qw (
	0 modeNone
	1 modeDataServices
	2 modeDownload
	3 modeDiagnostic
	4 modeDiagnosticOffline
	5 modeReset
	6 modeStreamDownload) ;
	
my %phone_status_list = qw (
    0 phoneStatusNone
    1 phoneStatusInitializationInProgress
    2 phoneStatusPortNotPresent
    3 phoneStatusPhoneNotPresent
    4 phoneStatusPhoneNotSupported
    5 phoneStatusReady) ;

sub qpstInitiate{
print "QPST Initializing...\n\n";
$qpst = Win32::OLE->new($prod_id) or return 0;
# $qpst->ShowWindow();
sleep(1);
return 1;
}

sub findDevice{

my $port_list;
my $phone_count;
my $port_name; 
my $port_label;
my $is_usb;
my $thisport_id;
my $mode;
my $phone_status; 
my @port_id; 

$port_list = $qpst->GetPortList();
sleep (2);
$phone_count = $port_list->PhoneCount;
	if(0 != $phone_count)
	{
		for(my $i=0; $i < $phone_count; $i++)
		{
			$port_name = $port_list->PortName($i);
			$port_label = $port_list->PortLabel($i);
			$is_usb = $port_list->IsUSB($i);
			$thisport_id = $port_list->PortId($i);
			$mode = $phone_mode_list{$port_list->PhoneMode($i)};
			$phone_status = $phone_status_list{$port_list->PhoneStatus($i)};

			if ($phone_status eq "phoneStatusReady")
			{
				# print "Device enumerated on QPST\n";
				# $port_id = $thisport_id;
				push(@port_id, $thisport_id);
				# return 1;
			}
		}	
	}
	else
	{
		print "Device not connected\n";
	}
	return @port_id;
}

sub SendCommand{
	my $timeout_in_ms = 2000;
	my $diag_request_var;
	my $diag_reply;
	my @diag_resp;
	my $diag_cmd;
	my $value = 0;

	# $ret = findDevice();
	# if ($ret == 0){
		# print "qpstInitiate Error\n";
		# exit;
	# }

	$TargetPort = $qpst->GetPort($uport_id);
	if (defined $TargetPort){
		$diag_cmd = pack("CC*", @_);
		$diag_request_var = Variant(VT_ARRAY | VT_UI1, length $diag_cmd);
		$diag_request_var->Put($diag_cmd); 
		$diag_reply = $TargetPort->SendCommand($diag_request_var, $timeout_in_ms);
	
			@diag_resp = unpack "C*", $diag_reply;
			# print join(",",@_),"\n\n";
			# print "Diag Response: ";
			# print join(",",@diag_resp),"\n\n";
			# join(",",@diag_resp);
			return @diag_resp;
	}
	else{
		print "send command error";
	}
} 

sub scan{
		print $iterations;
		for(my $i=0; $i < $iterations; $i++)
		{
			print "Iteration_$i\n";
			system("cls");
			my @diag_scan = (75, 41, 11, 0, 0);
			# SendCommand(@diag_scan);
			sleep 1;
		}
}

sub connect_disconnect{ 
		my $iterations=@_[0];
		my $index=@_[1];
		print $iterations, $index;
		for(my $i=0; $i < $iterations; $i++)
		{			
			my @diag_con = (75, 41, 11, 0, 3, $index);
			my @diag_discon = (75, 41, 11, 0, 4, $index);	
			print "Connect...\n";			
			# SendCommand(@diag_con);
			print "DisConnect...\n";
			# SendCommand(@diag_discon);
			sleep 1;
		}	
		<STDIN>;
}

sub get_ssid{

		system("cls");
		my @ap_data;
		my @diag_scan = (75, 41, 11, 0, 0);
		my @diag_count = (75, 41, 11, 0, 1);
		my $serial=0;		
		
		SendCommand(@diag_scan);
		sleep 1;
		my @total_aps =SendCommand(@diag_count);
		print "AP Count is $total_aps[6]\n";
		<STDIN>;		

		for (my $i=0 ; $i < $total_aps[6]; $i++){
			my @diag_getdata = (75, 41, 11, 0, 2, );
			push(@diag_getdata, "$i");
			my @sample=SendCommand(@diag_getdata);
			print "$sample";
			push(@ap_data, "@sample");
			push(@ap_data, "\n");	
		}
		s/ /,/g for @ap_data;

		print "INDEX\t\tSSID\n";
		print "-----\t\t----\n";
		
		foreach (@ap_data)
		{				
			if ($_!= " "){
				my @ssids=();
				my @splitter = split(/,/, $_);
				my $ssid_lenght=$splitter[6];
				my $ssid_lenght2=$ssid_lenght+6;				
				for (my $i=7; $i<=$ssid_lenght2; $i++)
				{
					push(@ssids,"$splitter[$i]");
				}
				join(",",@ssids);				
				my $word = pack("C*", @ssids);			
				print "$serial\t$word\n";
				$serial=$serial+1;
			}
		}
}

sub SAP_STA{
		print"No.of Iterations:";
		my $iterations = <STDIN>;
		
		my @diag_tx = (75, 41, 11, 0, 6, );
		# SendCommand(@diag_scan);
		
		for(my $i=0; $i < $iterations; $i++)
		{
			system("cls");

			# SendCommand(@diag_scan);
			print "scan_$i\n";
			sleep 1;
		}
}

sub adb_device()
{
	# system("cls");
	# system("adb devices");
	# print"Enter device id:";
	# my $dev_id=<STDIN>;
	# chomp($dev_id);
}

# system("cls");
# my $ret = qpstInitiate();
# if ($ret == 0){
	# print "qpstInitiate Error\n";
	# exit;
# }



# my @port_id=findDevice();
# foreach (@port_id)
# {
# print "Device enumerated on QPST::$_\n";
# }
# print"Enter QPST id:";
# $uport_id=<STDIN>;
# chomp($uport_id);

while (1){
	system("cls");
	$CONSOLE->Title("FIT");
	print "0.Reboot\n";
	print "1.Back to Back Scan\n";
	print "2.Connect Disconnect 2G\n";
	print "3.Connect Disconnect 5G\n";
	print "4.Connect Disconnect 2G/5G\n";
	print "5.Connect 2G TX Packet Disconnect\n";
	print "6.Connect 5G TX Packet Disconnect\n";
	print "7.SAP ON STA Scan Connect Disconnect\n";

	print"Enter Choice:";
	my $choice = <STDIN>;
	

	if($choice == 0) {

		system("adb -s $dev_id shell reboot");
		system("cls");
		system("adb -s $dev_id wait-for-device root");
		print "Device reconnecting\n";
		sleep 10;
		system("adb -s $dev_id wait-for-device root");
		system("adb -s $dev_id wait-for-device root");
		
		`adb -s $dev_id shell "echo 2 > /d/icnss/test_mode"`;
		`adb -s $dev_id shell "echo 2 > /d/icnss/test_mode"`;
		`adb -s $dev_id shell "echo 2 > /d/icnss/test_mode"`;
			
		print "Initializing ...\n";
		sleep 20;
	}
	elsif($choice == 1) {
		$CONSOLE->Title("B2B_Scan");
		print"No.of Iterations:";
		$iterations = <STDIN>;
		scan($iterations);
	}
	elsif($choice == 2) {	
		$CONSOLE->Title("connect_disconnect_2G");
		print"No.of Iterations:";
		my $iterations = <STDIN>;
		# get_ssid();
		print"Enter 2G AP Index value:";
		my $index = <STDIN>;	
		connect_disconnect($iterations,$index);
	}
	elsif($choice == 3) {	
		$CONSOLE->Title("connect_disconnect_5G");
		print"No.of Iterations:";
		my $iterations = <STDIN>;
		# get_ssid();
		print"Enter 5G AP Index value:";
		my $index = <STDIN>;	
		connect_disconnect($iterations,$index);
	}
	elsif($choice == 4) {	
		$CONSOLE->Title("connect_disconnect_2G/5G");
		print"No.of Iterations:";
		my $iterations = <STDIN>;
		# get_ssid();
		print"Enter 2G AP Index value:";
		my @index;
		$index[0] = <STDIN>;		
		print"Enter 5G AP Index value:";
		$index[1] = <STDIN>;
		for(my $i=0; $i < $iterations; $i++)
		{				
			for(my $j=0; $j <2; $j++)
			{				
				system("cls");
				print "Iteration_$i\n";
				connect_disconnect(1,$index[$j]);
			}
		}
		
	}
	else{
		print "No/Wrong input recieved";
		<STDIN>;
	}
}