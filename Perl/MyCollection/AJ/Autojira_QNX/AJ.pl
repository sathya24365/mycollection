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

our $OUT = Win32::Console->new(STD_OUTPUT_HANDLE);
our $clear_string = $OUT->Cls;
print $clear_screen;

@months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
@weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);

our @comport;
our @meta;
our @ptag;
our @ext;
our @tc;

our $station = `hostname`;
chomp ($station);

our $port;
our $port_name;
our $port_status;
our $port_mode;
our $dump;
our $i=0;

our $path1 = '\\\\hope\\SNS-ODC-TESTING';
our $path2 = '\\\\hope\\SNS-ODC-TESTING2';
our $path3 = '\\\\sun\\SNS-ODC-TESTING1';

($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
$year = 1900 + $yearOffset;		
our $time = "$hour-$minute-$second-$weekDays[$dayOfWeek].$months[$month].$dayOfMonth.$year";	

Cleanup();
sleep 2;

LaunchQPST();
sleep 5;

our $clear_string = $OUT->Cls;
print $clear_screen;

getdata();

while(1){
	
	# our $clear_string = $OUT->Cls;
	# print $clear_screen;

		DiskSpace();
		print "\n";
	
		($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
		$year = 1900 + $yearOffset;		
		$time = "$hour-$minute-$second-$weekDays[$dayOfWeek].$months[$month].$dayOfMonth.$year";
		
		undef $port_status;
		undef $port_mode;
		
		GetPort();
			
		# print "$phone_status_list{$port_status}\n";
		# print "$port_mode\n";
		# print "Press enter to Exit";
		# <STDIN>;
		
		if($phone_status_list{$port_status} eq "phoneStatusReady" && $port_mode eq 2) 
		{
				our $clear_string = $OUT->Cls;
				print $clear_screen;
				print "phone is in crashed state in Non-sahara mode\n";
				CollectCrashDump();
				sleep 5;	
		}
		else{
			print "phone isn't in crashed state\n";
			sleep 5;
		}
		
		
	}	

print "Press enter to Exit";
<STDIN>;
###########################################END#######################################################################

	
sub CollectCrashDump{	

	my $Directoryname_dest="c:\\RAMDUMPS".$ext[$i].$ptag[$i]."\\".$tc[$i]."\\".$time;
	print "Creating $Directoryname_dest\n";
	mkpath "$Directoryname_dest";

	my $memory_debug = $port->{MemoryDebug};
	$memory_debug->{UseUnframedMemoryRead} = 1;

	if (defined $memory_debug)
	{

		print "Wait for 20Min, Saving Ramdump to folder $Directoryname_dest \n";
		$memory_debug->SaveAllRegions("$Directoryname_dest");
		print "Crash dump saved, reset device.\n";
		
	}
	else
	{
		  print "No MemoryDebug interface for this port\n";
	}
	
	my $Directoryname_source=$Directoryname_dest;
	print "Directoryname_source: $Directoryname_source\n";
	
	my $Directoryname_dest=$dump."\\".$serials."\\".$tc."\\".$time;
	print "Directoryname_dest: $Directoryname_dest\n";
	mkpath "$Directoryname_dest";	
	$port->Reset();
	
	system("start cmd /c perl CS.pl $Directoryname_source $Directoryname_dest $meta[$i] $ptag[$i].xml $dump");

}
	
sub Cleanup{

	system('TASKKILL /F /IM  QPSTServer.exe /T');
	system('TASKKILL /F /IM  QPSTConfig.exe /T');
	system('TASKKILL /F /IM  MemoryDebugApp.exe /T');
	system('TASKKILL /F /IM  AtmnServer.exe /T');
	
}

sub GetPort{

print "\n";
my $com=$comport[$i];
print "Current comport is $com\n";

if (defined $qpst)
		{		
			eval{$port = $qpst->GetPort($com) }; warn() if $@;
			%phone_status_list = qw (
			0 phoneStatusNone
			5 phoneStatusReady) ;
		
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
	
	# print "$i is selected for copying\n";
	# print "$ext[$i] is selected for copying\n";
	# print "Press enter to Exit";
	# <STDIN>;
	
	if ($freeSpaceForUser1 > 20) {
		
		$dump="$path1".$ext[$i]."$station";
		print "$path1 is selected for copying\n";
	}
	elsif  ($freeSpaceForUser2 > 20){ 
		
		$dump="$path2".$ext[$i]."$station";
		print "$path2 is selected for copying\n";
	}
	elsif ($freeSpaceForUser3 > 20){ 
		
		$dump="$path1".$ext[$i]."$station";
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

########################################################################
	#reading comport.txt
	open F, "comport.txt" or die "cannot open comport.txt\n";
	my @data = <F>;

	for (my $i=0; $i<@data; $i++)
	{
	   chomp $data[$i];
	   #print "this is the Device list: $data[$i] \n]";
	   next if ($data[$i] =~ /^\s*$/); 
	   push (@comport,split(',', $data[$i]));
	}	  
	close F; 
	undef @data;
	
	#printing comport.txt
	print "\nThe comports are::";
	for (my $i=0; $i<@comport; $i++)
	{
		print "$comport[$i] \n";
	}
########################################################################
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
	print "Meta details::";
	for (my $i=0; $i<@meta; $i++)
	{
		print "$meta[$i] \n";
	}
########################################################################	

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
	print "Test Scenario::";
	for (my $i=0; $i<@tc; $i++)
	{
		print "$tc[$i]\n";
	}
		
########################################################################	

	#reading ptag.txt
	open F, "ptag.txt" or die "cannot open ptag.txt\n";
	my @data = <F>;

	for (my $i=0; $i<@data; $i++)
	{
	   chomp $data[$i];
	   #print "this is the Device list: $data[$i] \n]";
	   next if ($data[$i] =~ /^\s*$/); 
	   push (@ptag,split(',', $data[$i]));
	}	  
	close F; 	
	undef @data;
	print "\n";
	
	#printing ptag.txt
	print "Device PTAG Details::";
	for (my $i=0; $i<@ptag; $i++)
	{
		print "$ptag[$i]\n";
	}
	
########################################################################
	
	#reading ext.txt
	open F, "ext.txt" or die "cannot open ext.txt\n";
	my @data = <F>;

	for (my $i=0; $i<@data; $i++)
	{
	   chomp $data[$i];
	   next if ($data[$i] =~ /^\s*$/); 
	   push (@ext,split(',', $data[$i]));
	}	  
	close F; 	
	undef @data;
	
	#printing ext.txt
	print "\n";
	print "Ext details::";
	for (my $i=0; $i<@ext; $i++)
	{
		print "$ext[$i] \n";
	}	
########################################################################
	print "\n";
	print "Get Data is done! \n";
	print "Press enter to Continue";
	<STDIN>;
}