use Getopt::Long;
use Win32::OLE;
use Win32::OLE::Variant;
use Win32::Console;
use Time::Local;
use File::Find;
use File::Copy;
use File::Path; 
use Cwd;
# use Cwd qw(abs_path);
use Scenario;


our $comport=$ARGV[0];
our $serials=$ARGV[1];
our $dump=$ARGV[2];
our $time=$ARGV[3];

our $cwd=getcwd;
our $station = `hostname`;

@months = qw(01 02 03 04 05 06 07 08 09 10 11 12);

($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
$year = 1900 + $yearOffset;	
	
if ($dayOfMonth == 1 || $dayOfMonth == 2 || $dayOfMonth == 3|| $dayOfMonth == 4|| $dayOfMonth == 5|| $dayOfMonth == 6|| $dayOfMonth == 7|| $dayOfMonth == 8|| $dayOfMonth == 9)
{

$dayOfMonth= "0".$dayOfMonth;

}

if ($hour == 1 || $hour == 2 || $hour == 3|| $hour == 4|| $hour == 5|| $hour == 6|| $hour == 7|| $hour == 8|| $hour == 9)
{

$hour= "0".$hour;

}

my $date = "$months[$month]-$dayOfMonth-$year";
our $logs_source="c:\\Android"."\\".$date."\\".$serials;

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

if (defined $qpst)
{
  $port = $qpst->GetPort($comport);
  
}
else
{
  print "QPST not available\n";
}

our $meta=Scenario::meta($serials);
our $pl=Scenario::pl($serials);
our $tc=Scenario::tc($serials);
our $ext=Scenario::ext($serials);

chomp ($cwd);
chomp ($station);
chomp $meta;
chomp $pl;
chomp $tc;
chomp $ext;


our $xml =$cwd."/".$pl."/".$serials.".xml";
our $cbuild =$cwd."/".$pl."/"."CustomBuildConfig.txt";

my @buildid = split(/\\/,$ext);

my $Directoryname_dest="c:\\RAMDUMPS"."\\".$buildid[scalar(@buildid)-1]."\\".$serials."\\"."P".$comport."\\".$time;
print "Creating $Directoryname_dest\n";
mkpath "$Directoryname_dest";

unless(-e $logs_source) 
{

	print"**************************************\n";
	print"$logs_source location not found\n";
	print"**************************************\n";

}
else
{	
	print "Copying Logs....";
	eval
	{
	  copy($logs_source."\\"."kmsg.txt", $Directoryname_dest."\\"."kmsg.txt") or print "KMSG File cannot be copied\n";
	  copy($logs_source."\\"."WifiLogger.txt", $Directoryname_dest."\\"."WifiLogger.txt") or print "\nWifiLogger File cannot be copied\n";
	  copy($logs_source."\\".$hour."\\"."logcat.txt", $Directoryname_dest."\\"."logcat.txt") or print "\nlogcat File cannot be copied\n";
	};		
}

open(DATA, ">$Directoryname_dest/Scenario.txt");
print DATA $tc;
close( DATA );

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

	if ($dump eq 0) 
	{

		$port->Reset();	
		sleep 5;
		print "Local copy done\n";
		exit;
		
	}
	else 
	{ 	

		$dump="$dump".$ext."$station";
		$Directoryname_source=$Directoryname_dest;
		print "Directoryname_source: $Directoryname_source\n";
		
		$Directoryname_dest=$dump."\\".$serials."\\"."P".$comport."\\".$time;
		print "Directoryname_dest: $Directoryname_dest\n";
		mkpath "$Directoryname_dest";
		
		system("robocopy $Directoryname_source $Directoryname_dest /S /Z /B /ZB /R:300 /W:5");	
		$port->Reset();	
		
		unless(-e $cbuild) 
		{
			system("crashscope.exe","-batchMode","-metaBuild=$meta","-logDir=$Directoryname_dest","-config=$xml");
		}
		else
		{		
			system("crashscope.exe","-batchMode","-metaBuild=$meta","-logDir=$Directoryname_dest","-config=$xml","-custBuilds=$cbuild");
		}		
		
		print "Raising crashscope done\n";
		exit;
	
	
	}