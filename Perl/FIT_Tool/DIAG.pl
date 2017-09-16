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
sleep(1);
}

sub adb_devices(){
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
	exit;}
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

				push(@port_id, $thisport_id);

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

	$TargetPort = $qpst->GetPort($uport_id);
	if (defined $TargetPort){
		$diag_cmd = pack("CC*", @_);
		$diag_request_var = Variant(VT_ARRAY | VT_UI1, length $diag_cmd);
		$diag_request_var->Put($diag_cmd); 
		$diag_reply = $TargetPort->SendCommand($diag_request_var, $timeout_in_ms);
	}
	else{
		print "send command error";
	}
} 

sub scan{
		for(my $i=0; $i < $iterations; $i++)
		{
			print "Iteration_$i\n";
			system("cls");
			my @diag_scan = (75, 37, 03, 32);
			SendCommand(@diag_scan);
			sleep (60);
			my @diag_scan = (75, 37, 03, 32, 01);
			SendCommand(@diag_scan);
			sleep (60);
			my @diag_scan = (75, 37, 03, 32, 02);
			SendCommand(@diag_scan);
			sleep (60);
			my @diag_scan = (75, 37, 03, 32, 03);
			SendCommand(@diag_scan);
			sleep (60);
		}
}		




adb_devices()
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
	$CONSOLE->Title("DIAG");

	print"No.of Iterations:";
	$iterations = <STDIN>;
	scan($iterations);
}