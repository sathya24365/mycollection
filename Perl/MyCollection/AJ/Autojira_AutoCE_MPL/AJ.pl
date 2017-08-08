use Getopt::Long;
use Win32::OLE;
use Win32::OLE::Variant;
use Time::Local;
use File::Find;
use File::Path; 
use Cwd;
use Win32::Console;
use Win32::DriveInfo;
use Win32::FileOp;
use Cwd;   
use Cwd qw(abs_path);
use Spreadsheet::ParseExcel;
use Exporter;


my $cwd = getcwd;
our $OUT = Win32::Console->new(STD_OUTPUT_HANDLE);
our $clear_string = $OUT->Cls;
print $clear_screen;

@months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
@weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);

our @comport;
our @serials;
our @meta;
our @pl;
our @crashlist;
our @DeviceCrashed;
our @ext;
our @hwid;

our @adbid;
our @portid;

our $TotalDevices =0;
our $port;
our $port_name;
our $port_status;
our $port_mode;
our $dump;

our $path1 = '\\\\hope\\SNS-ODC-TESTING';
our $path2 = '\\\\hope\\SNS-ODC-TESTING2';
our $path3 = '\\\\sun\\SNS-ODC-TESTING1';

($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
$year = 1900 + $yearOffset;		
our $time = "$hour-$minute-$second-$weekDays[$dayOfWeek].$months[$month].$dayOfMonth.$year";	

my $ldir = getcwd;
Cleanup();
sleep 2;

LaunchQPST();
sleep 5;

our $clear_string = $OUT->Cls;
print $clear_screen;

getdata();
status();

my $count=0;

foreach my $value1(@adbid){
	foreach my $value2(@hwid){
		if($value1 =~ m/$value2/){	
			$count++;
		}
	}
}


if (scalar(@meta) eq scalar(@adbid) && scalar(@ext) eq scalar(@adbid)&& scalar(@pl) eq scalar(@adbid)&& scalar(@tc) eq scalar(@adbid)&& scalar(@hwid) eq scalar(@adbid)&& $count eq scalar(@adbid) )
{
	print "\nGet Data is done! \n";
	print "\nPress any key to continue...\n";
	<STDIN>;
}
else{	

	print "\nError:".scalar(@adbid),scalar(@pl),scalar(@hwid),scalar(@tc),scalar(@meta),scalar(@ext);
	print("\nData Miss-match");
	print "\nPress any key to Exit...\n";
	<STDIN>;
	exit;

}


while(1){
	
	# our $clear_string = $OUT->Cls;
	# print $clear_screen;
	for (our $i=0; $i<$TotalDevices; $i++)
	{
		DiskSpace();
		print "\n";
		print "Device $i status\n";
		print "**********************\n";
		print "Monitoring $adbid[$i] \n";
		
		($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
		$year = 1900 + $yearOffset;		
		$time = "$hour-$minute-$second-$weekDays[$dayOfWeek].$months[$month].$dayOfMonth.$year";
		
		undef $port;
		undef $port_name;
		undef $port_status;
		undef $port_mode;
		
		GetPort();
			
		if($phone_status_list{$port_status} eq "phoneStatusNone" && $port_mode eq 0) 
		{
			$DeviceCrashed[$i] =0;
			print "Phone is Booting / Disconnected\n";
		}
	
		if($phone_status_list{$port_status} eq "phoneStatusReady" && $port_mode eq 12) 
		{
		
			# sahara mode
			
		}
		elsif($phone_status_list{$port_status} eq "phoneStatusReady" && $port_mode eq 2) 
		{

			# Non-sahara mode	
			print "$DeviceCrashed status is ::$DeviceCrashed[$i]\n";
			if ($DeviceCrashed[$i] eq 0 && $port_mode eq 2) 
			{
				print "phone is in crashed state in non-sahara mode\n";
				CollectCrashDump_2();
				sleep 5;
			} 
			else
			{
				print "phone is in crashed state\n";
				print "CS already running for this crash\n";
				sleep 1;
			}			
			
		}
		else{
			$DeviceCrashed[$i] =0;
			print "phone isn't in crashed state\n";
			sleep 5;
		}
		
		
	}
}	


###########################################END#######################################################################


sub CollectCrashDump_12{	

# Never comes here

}

sub CollectCrashDump_2{	

	$DeviceCrashed[$i]=1;
	DiskSpace();	
	system("start cmd /k perl CS.pl $portid[$i] $adbid[$i] $dump $time");

}
	
sub Cleanup{

	system('TASKKILL /F /IM  QPSTServer.exe /T');
	system('TASKKILL /F /IM  QPSTConfig.exe /T');
	system('TASKKILL /F /IM  MemoryDebugApp.exe /T');
	system('TASKKILL /F /IM  AtmnServer.exe /T');
	
}

sub GetPort{

print "\n";
my $com=$portid[$i];
print "Current comport is $com\n";

	if (defined $qpst)
		{		
			eval{$port = $qpst->GetPort($com) }; warn() if $@;
			%phone_status_list = qw (
			0 phoneStatusNone
			5 phoneStatusReady) ;
		
			eval{$port_name = $port->PortName }; 
			eval{$port_status = $port->PhoneStatus }; 
			eval{$port_mode = $port->PhoneMode }; 
		}
		else{
			print "QPST Busy\n";
		}
}

sub LaunchQPST {

	print "Launching QPST application\n";
	system 1, "C:\\Program Files (x86)\\Qualcomm\\QPST\\bin\\QPSTConfig.exe";
	sleep 5;
	$Application = "QPSTAtmnServer.Application";
	eval
	{
		$qpst = Win32::OLE->GetActiveObject($Application);
	}; 
	
	die "$Application not installed" if $@;

	unless (defined $qpst)
	{
		$qpst = Win32::OLE->new($Application, sub {$_[0]->Quit;}) or die "Oops, cannot start $Application";
	}

}

sub DiskSpace{

	my ($freeSpaceForUser1) = GetDiskFreeSpace $path1;
	my ($freeSpaceForUser2) = GetDiskFreeSpace $path2;
	my ($freeSpaceForUser3) = GetDiskFreeSpace $path3;

	
	my $freeSpaceForUser1 = int($freeSpaceForUser1/(1024*1024*1024)) ;
	my $freeSpaceForUser2 = int($freeSpaceForUser2/(1024*1024*1024)) ;
	my $freeSpaceForUser3 = int($freeSpaceForUser3/(1024*1024*1024)) ;

	my $freeSpaceForUser;
	
	our $clear_string = $OUT->Cls;
	print $clear_screen;
	
	print "$path1 @ $freeSpaceForUser1 GB \n";
	print "$path2 @ $freeSpaceForUser2 GB \n";
	print "$path3 @ $freeSpaceForUser3 GB \n";
	print "\n";
	
	if ($freeSpaceForUser1 > 20) {
		
		# $dump="$path1".$ext[$i]."$station";
		$dump=$path1;
		print "$path1 is selected for copying\n";
	}
	elsif  ($freeSpaceForUser2 > 20){ 
		
		# $dump="$path2".$ext[$i]."$station";
		$dump=$path2;
		print "$path2 is selected for copying\n";
	}
	elsif ($freeSpaceForUser3 > 20){ 
		
		# $dump="$path3".$ext[$i]."$station";
		$dump=$path3;
		print "$path3 is selected for copying\n";
	}
	else {
		
		$dump=0;
		print "No repository is selected for copying\n";
	}
	
	# print "Dump location : $dump";
	# print "\n";

}

sub getdata{

	if (defined $qpst)
	{
	  my $port_list = $qpst->GetCOMPortList();

	  if (defined $port_list) 
	  {
			my $port_count = $port_list->PortCount;

			for ($i = 0 ; $i < $port_count ; $i++)
			{
				# COM port name (e.g. "COM1")
				my $port_name = $port_list->PortName($i);
				$description = $port_list->DeviceDescription($i);
				my $substring="Qualcomm HS-USB MSM Diagnostics";

				if ($description =~ /\Q$substring\E/)
				{
					my @desc = split(':', $description);
					chop($desc[1]);
					push (@adbid, "$desc[1]");
					push (@portid, "$port_name");
				}
			}	
		}	
	}
	
	# print "\n";
	for (my $i=0; $i<@adbid; $i++)
	{
		print "Hello $portid[$i] $adbid[$i] \n";
		$TotalDevices = 1+ $i;	
		push (@DeviceCrashed,0);
	}
	print "\n";
	
}


sub status{

    my $parser   = Spreadsheet::ParseExcel->new();
    my $workbook = $parser->parse('Book.xls');

    if ( !defined $workbook ) {
        die $parser->error(), ".\n";
    }

	for my $worksheet ( $workbook->worksheets() ) {
		
		my ( $row_min, $row_max ) = $worksheet->row_range();
		my ( $col_min, $col_max ) = $worksheet->col_range();

		for my $row ( $row_min .. $row_max ) {
			for my $col ( $col_min .. $col_max ) {
				
				if($col eq 0) 
				{ 
					my $cell = $worksheet->get_cell( $row, $col );
					next unless $cell;

					# print $cell->value();
					# print "\n";
					if(!$cell->value() eq ''){
					
						push (@pl,$cell->value());
						chomp @pl;
					}

				}
				elsif($col eq 1)
				{		
					my $cell = $worksheet->get_cell( $row, $col );
					next unless $cell;			
					# print $cell->value();
					# print "\n";
					if(!$cell->value() eq ''){
					
						push (@hwid,$cell->value());
						chomp @hwid;
						
					}					
				}
				elsif($col eq 2)
				{		
					my $cell = $worksheet->get_cell( $row, $col );
					next unless $cell;			
					# print $cell->value();
					# print "\n";
					
					if(!$cell->value() eq ''){
					
						push (@tc,$cell->value());
						chomp @tc;
						
					}					
				}
				elsif($col eq 3)
				{		
					my $cell = $worksheet->get_cell( $row, $col );
					next unless $cell;			
					# print $cell->value();
					# print "\n";
					# <STDIN>;
					if(!$cell->value() eq ''){
					
						push (@meta,$cell->value());
						chomp @meta;
					}		
				}
				elsif($col eq 4)
				{		
					my $cell = $worksheet->get_cell( $row, $col );
					next unless $cell;			
					# print $cell->value();
					# print "\n";
					if(!$cell->value() eq ''){
					
						push (@ext,$cell->value());
						chomp @ext;
					}
				}
				
			}
		}

	}
	
	for (my $i=0; $i<@meta; $i++)
	{
		print "$hwid[$i]\n";
	}
	print "\n";
	for (my $i=0; $i<@meta; $i++)
	{
		print "$meta[$i]\n";
	}	
	print "\n";
	for (my $i=0; $i<@ext; $i++)
	{
		print "$ext[$i]\n";
	}	
}