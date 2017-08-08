use Getopt::Long;
use Win32::OLE;
use Win32::OLE::Variant;
use Win32::Console;
use Time::Local;
use File::Find;
use File::Path; 
use Cwd;
use Cwd qw(abs_path);
use PID;


my $cwd=getcwd;
our $comport=$ARGV[0];
our $dump=$ARGV[1];
our $meta=$ARGV[2];
our $pl=$ARGV[3];
our $tc=$ARGV[4];
our $serials=$ARGV[5];
our $time=$ARGV[6];
our $f=$ARGV[7];
our $Directoryname_source="C:\\ProgramData\\Qualcomm\\QPST\\Sahara\\Port_$comport";
our $ppid=$$;

our $OUT = Win32::Console->new(STD_OUTPUT_HANDLE);

# print "Parent Process ID id is $ppid \n";
open(DATA0, ">$cwd/PPID/$f.txt");
print DATA0 $ppid;
close( DATA0 );

	if ($dump eq 0) 
	{
		my $Directoryname_dest="c:\\RAMDUMPS_PC"."\\".$serials."\\".$tc."\\".$time;
		print "Creating $Directoryname_dest\n";
		mkpath "$Directoryname_dest";
		print "Wait Saving Ramdump to folder $Directoryname_dest \n";
		sleep 120;
	
		system("robocopy $Directoryname_source $Directoryname_dest /S /Z /B /ZB /MOVE /R:300 /W:5");				
		sleep 5;
		print "Local copy done\n";
		exit;
		
	}
	else 
	{ 
		my $Directoryname_dest="c:\\RAMDUMPS_CC"."\\".$serials."\\".$tc."\\".$time;
		print "Creating $Directoryname_dest\n";
		mkpath "$Directoryname_dest";
				
				
		print "Wait Saving Ramdump to folder $Directoryname_dest \n";
		sleep 30;

		system("robocopy $Directoryname_source $Directoryname_dest /S /Z /B /ZB /MOVE /R:300 /W:5");				
		sleep 5;		
				
		my $Directoryname_source=$Directoryname_dest;
		print "Directoryname_source: $Directoryname_source\n";
				
		my $Directoryname_dest=$dump."\\".$serials."\\".$tc."\\".$time;
		print "Directoryname_dest: $Directoryname_dest\n";
		mkpath "$Directoryname_dest";
		
		start_rep_copy();
				
		system("robocopy $Directoryname_source $Directoryname_dest /S /Z /B /ZB /R:300 /W:5");	
		
		open(DATA2, ">$cwd/CPID/$f.txt");
		print DATA2 0;
		close( DATA2 );
		
		system("crashscope.exe","-batchMode","-metaBuild=$meta","-logDir=$Directoryname_dest","-config=$pl");
		print "Raising crashscope done\n";
		exit;		
	}
	
	
	
sub start_rep_copy{

	my $loop=1;
	my $tf=$f-1;

	while($loop > 0)
	{
		
		open (DATA3, "<$cwd/CPID/$tf.txt");
		open (DATA4, "<$cwd/PPID/$tf.txt") ;
		
		while (<DATA3>) 
		{
			our $cpid=$_;		
			close (DATA3);
			# print "cpid is $cpid \n";
		}
		
		while (<DATA4>) 
		{
			$ppid=$_;		
			chomp($ppid);
			# print "ppid is $ppid \n";
			close (DATA4);
		}

			my $ppid = PID::Status($ppid);
			our $clear_string = $OUT->Cls;
			print $clear_screen;
			# print "ppid is $ppid\n";
			
		
			if($cpid == 0) 
			{
				
				print "Repository Copy started\n";
				$loop=0;
			}
			elsif($cpid == 1 && $ppid == 0)
			{
			
				print "Previous Process is terminated\n";
				print"Enabling Force Copy....\n";
				sleep 1;
				$loop=0;
			}
			else 
			{			
				print"Plz wait prev Copy is in progress....\n";
				sleep 1;
			}
	}
	
}