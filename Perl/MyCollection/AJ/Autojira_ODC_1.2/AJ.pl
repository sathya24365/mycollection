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

our @adbid;
our @portid;

our $TotalDevices =0;
our $station = `hostname`;
chomp ($station);
our $port;
our $port_name;
our $port_status;
our $port_mode;
our $dump;
our $f=0;

system ("del /Q %cd%\\CPID\\*.*");
system ("del /Q %cd%\\PPID\\*.*");

open(DATA, ">$cwd/CPID/$f.txt");
print DATA 0;
close( DATA );

open(DATA, ">$cwd/PPID/$f.txt");
print DATA 0;
close( DATA );


# Example '\\PL\\META\\APPS\\PR\\';

our $ext = '\\MSM8939.LA.2.0.C4\\M8939BAAAAULGD20040002H.1\\CNSS.PR.2.0.1.c5-00003\\';
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

while(1){

	
	our $clear_string = $OUT->Cls;
	print $clear_screen;
	sleep 1;
	DiskSpace();

	for (our $i=0; $i<$TotalDevices; $i++)
	{
		
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
		# print "Port mode is $port_mode \n";
		# print "port_status is $phone_status_list{$port_status} \n";
			
		if($phone_status_list{$port_status} eq "phoneStatusNone" && $port_mode eq 0) {
			$DeviceCrashed[$i] =0;
			print "Phone is Booting\n";
			# print "DeviceCrashed[$i] is $DeviceCrashed[$i] \n";
		}
	
		if($phone_status_list{$port_status} eq "phoneStatusReady" && $port_mode eq 12) {
			
			# print "Port mode is $port_mode \n";
			# print "port_status is $phone_status_list{$port_status} \n";
			# print "1.DeviceCrashed[$i] is $DeviceCrashed[$i] \n";
			if ($DeviceCrashed[$i] eq 0 && $port_mode eq 12) 
			{
				print "phone is in crashed state in sahara mode\n";
				CollectCrashDump_12();
				sleep 5;
			} 
			else {
					print "phone is in crashed state\n";
					print "CS already running for this crash\n";
					sleep 1;
			}
			
		}
		elsif($phone_status_list{$port_status} eq "phoneStatusReady" && $port_mode eq 2) {

			# print "phone is in crashed state in non-sahara mode\n";
			# CollectCrashDump_2();
			# sleep 5;
		} 
		else{
			print "phone isn't in crashed state\n";
			sleep 5;
		}
		
		
	}
}	

print "Press enter to Exit";
<STDIN>;
###########################################END#######################################################################


	
sub CollectCrashDump_12{	

	# print"f is $f\n";
	$f++;
	# print"f is $f\n";

	open(DATA, ">$cwd/CPID/$f.txt");
	print DATA 1;
	close( DATA );


	# print "2.DeviceCrashed[$i] is $DeviceCrashed[$i] \n";
	$DeviceCrashed[$i]=1;
	# print "3.DeviceCrashed[$i] is $DeviceCrashed[$i] \n";
	
	my $dir='c:\\RAMDUMPS\\$serial\\$tc\\$time\\';	
	DiskSpace();
	system("start cmd /c perl CS.pl $portid[$i] $dump $meta[$i] $adbid[$i].xml $tc[$i] $adbid[$i] $time $f");

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
}

sub DiskSpace{

	my ($freeSpaceForUser1) = GetDiskFreeSpace $path1;
	my ($freeSpaceForUser2) = GetDiskFreeSpace $path2;
	my ($freeSpaceForUser3) = GetDiskFreeSpace $path3;

	
	my $freeSpaceForUser1 = int($freeSpaceForUser1/(1024*1024*1024)) ;
	my $freeSpaceForUser2 = int($freeSpaceForUser2/(1024*1024*1024)) ;
	my $freeSpaceForUser3 = int($freeSpaceForUser3/(1024*1024*1024)) ;
	my $freeSpaceForUser3 = int($freeSpaceForUser3/(1024*1024*1024)) ;
	my $freeSpaceForUser;
	
	our $clear_string = $OUT->Cls;
	print $clear_screen;
	
	print "$path1 @ $freeSpaceForUser1 GB \n";
	print "$path2 @ $freeSpaceForUser2 GB \n";
	print "$path3 @ $freeSpaceForUser3 GB \n";
	print "\n";
	
	if ($freeSpaceForUser1 > 20) {
		
		$dump="$path1"."$ext"."$station";
		print "$path1 is selected for copying\n";
	}
	elsif  ($freeSpaceForUser2 > 20){ 
		
		$dump="$path2"."$ext"."$station";
		print "$path2 is selected for copying\n";
	}
	elsif ($freeSpaceForUser3 > 20){ 
		
		$dump="$path1"."$ext"."$station";
		print "$path3 is selected for copying\n";
	}
	else {
		
		$dump=0;
		print "No repository is selected for copying\n";
	}
	
	print "Dump location : $dump";
	print "\n";

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
				my $substring="Qualcomm HS-USB Diagnostics";

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
	
	for (my $i=0; $i<@adbid; $i++)
	{
		print "Hello $portid[$i] $adbid[$i] \n";
	}	

	#reading meta.txt
	open F, "meta.txt" or die "cannot open meta.txt\n";
	my @data = <F>;

	for (my $i=0; $i<@data; $i++)
	{
	   chomp $data[$i];
	   next if ($data[$i] =~ /^\s*$/); 
	   push (@meta,split(',', $data[$i]));
	}	  
	close F; 	
	undef @data;
	
	#printing meta.txt
	print "\n";
	print "Meta details::\n";
	for (my $i=0; $i<@meta; $i++)
	{
		# my $j=$i+1;
		print "$meta[$i] \n";
	}	

	for (my $i=0; $i<@adbid; $i++)
	{
		$TotalDevices = 1+ $i;	
	}
	
	for (my $i=0; $i<$TotalDevices; $i++)
	{
	   push (@DeviceCrashed,0);
	}	
	
	# print "\n";
	# print "Crashed Devices are";
	# for (my $i=0; $i<@DeviceCrashed; $i++)
	# {
		# print "$DeviceCrashed[$i]";
	# }

	#reading tc.txt
	open F, "tc.txt" or die "cannot open tc.txt\n";
	my @data = <F>;

	for (my $i=0; $i<@data; $i++)
	{
	   chomp $data[$i];
	   #print "this is the Device list: $data[$i] \n]";
	   next if ($data[$i] =~ /^\s*$/); 
	   push (@tc,split(',', $data[$i]));
	}	  
	close F; 	
	undef @data;
	print "\n";
	
	#printing tc.txt
	print "Test Scenario::\n";
	for (my $i=0; $i<@tc; $i++)
	{
		print "$tc[$i]\n";
	}
	
	print "\n";
	print "Get Data is done! \n";
	print "Press enter to Continue";
	<STDIN>;
}