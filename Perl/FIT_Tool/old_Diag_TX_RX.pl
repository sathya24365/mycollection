use Win32::OLE;
use Win32::OLE::Variant;
use Switch;
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


sub char_conver {
	my @data = @_;
	my $size = @data;
	print "size is:: @data";
	print "size is:: $size";
	
	
	my @words = split / /, @_;
	my $word = pack("C*", @words);	
	$word = pack("C*", @args); 
	print "$word\n";
}   

system("cls");
system("adb devices");
print"Enter device id:";
my $dev_id=<STDIN>;
chomp($dev_id);
$CONSOLE->Title($dev_id);

system("cls");
my $ret = qpstInitiate();
if ($ret == 0){
	print "qpstInitiate Error\n";
	exit;
}

my @port_id=findDevice();
foreach (@port_id)
{
print "Device enumerated on QPST::$_\n";
}
print"Enter QPST id:";
$uport_id=<STDIN>;
chomp($uport_id);

while (1){

system("cls");
print "0.Scan Device\n";
print "1.Device Reboot\n";
print "2.Scan\n";
print "3.Connect\n";
print "4.Disconnect\n";
print "5.SAP\n";

print"Enter Choice:";
$choice = <STDIN>;

if($choice == 0) {
	system("cls");
	system("adb -s $dev_id get-state");
	print "Enter to continue...\n";
	<STDIN>;
}
elsif($choice == 1) {

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
	sleep 45;
}
elsif($choice == 2) {
	system("cls");
	print "Scanning...\n";
	system('echo - > report.txt');
	my @diag_scan = (75, 41, 11, 0, 0);
	my @diag_count = (75, 41, 11, 0, 1);
	SendCommand(@diag_scan);
	sleep 1;
	my @total_aps =SendCommand(@diag_count);
	print "Count is $total_aps[6]\n";
	# <STDIN>;
	
	my @ap_data;
	for (my $i=0 ; $i < $total_aps[6]; $i++){
		my @diag_getdata = (75, 41, 11, 0, 2, );
		push(@diag_getdata, "$i");
		my @sample=SendCommand(@diag_getdata);
		print "$sample";
		push(@ap_data, "@sample");
		push(@ap_data, "\n");	
	}
	s/ /,/g for @ap_data;
	# print "@ap_data";

	my $serial=0;
	print "INDEX\tCHANNEL\tRSSI\tMAC\t\t\tSSID\n";
	print "-----\t-------\t----\t---\t\t\t----\n";
	
	foreach (@ap_data)
	{
			
			if ($_!= " "){
			my @ssids=();
			my @mac=();
			my @splitter = split(/,/, $_);
			my $ssid_lenght=$splitter[6];
			my $ssid_lenght2=$ssid_lenght+6;		
			my $channel=$ssid_lenght2+1;		
			my $rssi=$channel+1;
			my $mac_index=$ssid_lenght2+4;			
			# print "$splitter[$channel]\n";
			# print "$splitter[$rssi]\n";
			# print "$ssid_lenght2\n";
			for (my $i=7; $i<=$ssid_lenght2; $i++)
			{
				push(@ssids,"$splitter[$i]");
			}
			join(",",@ssids);
			for ($i=0; $i<6; $i++)
			{
				my $hex_string = sprintf("%X", $splitter[$mac_index]);
				push(@mac,"$hex_string");
				$mac_index=$mac_index+1;
			}
			# s/ /:/g for @mac;
			
			my $word = pack("C*", @ssids);
			
			open(my $fh, '>>', 'report.txt');
			print $fh "$serial\t$splitter[$channel]\t-$splitter[$rssi]\t@mac\t$word\n";
			close $fh;
			
			print "$serial\t$splitter[$channel]\t-$splitter[$rssi]\t@mac\t$word\n";
			$serial=$serial+1;
		}

	}
	# print "@ssids";
	print "Enter to continue...\n";
	<STDIN>;
}

elsif($choice == 3) {
	my @diag_con = (75, 41, 11, 0, 3, );
	my $filename = 'report.txt';
	open(my $fh, $filename)
	  or die "Could not open file '$filename' $!";
	 
	while (my $row = <$fh>) {
	  chomp $row;
	  print "$row\n";
	}
	print"Enter AP:";
	$i = <STDIN>;
	push(@diag_con, "$i");
	print "@diag_con";
	SendCommand(@diag_con);
	<STDIN>;
}
elsif($choice == 4) {
	my @diag_discon = (75, 41, 11, 0, 4, );
	my $filename = 'report.txt';
	open(my $fh, $filename)
	  or die "Could not open file '$filename' $!";
	 
	while (my $row = <$fh>) {
	  chomp $row;
	  print "$row\n";
	}
	print"Enter AP:";
	$i = <STDIN>;
	push(@diag_discon, "$i");
	print "@diag_discon";
	SendCommand(@diag_discon);
	<STDIN>;
}
elsif($choice == 5) {
	my @diag_sap = (75, 41, 11, 0, 5);
	SendCommand(@diag_sap);
	<STDIN>;
}
else{
	print "No/Wrong input recieved";
	<STDIN>;
}

}