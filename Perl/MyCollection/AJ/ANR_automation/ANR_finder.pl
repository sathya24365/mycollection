use warnings;
use Cwd;
use File::Copy;
use Net::FTP;    
use File::Copy;    
use File::Path;    
use Time::Local;     
use File::Basename;
print"Please enter Number of devices\n";
our @devi_id;
$Device_no = <STDIN>;
chomp($Device_no);
for ($i=0;$i<$Device_no;$i++)
{
print"Eneter Device ID:";
$device_id = <STDIN>;
chomp($device_id);
print"\n";
push(@devi_id,$device_id);
}
print "Total devices are @devi_id\n";
print"logs folder\n";
$LOG_Folder = <STDIN>;
chomp($LOG_Folder);
our $copy = 0;
my $dir = getcwd;
#our $destinatin = 'C:\Users\c_pyerra\Desktop\ANR_automation';
our $destinatin = getcwd;
system("perl find_subfolders.pl >folder.txt");
sleep 5;
open(FILE,"<folder.txt") or die "Canot open file $!\n";
@array = <FILE>;
my @filtered = uniq(@array);
close(FILE);
$count = 0;
foreach  $dev (@devi_id)
{
foreach $line (@filtered)
{
$log =0;
if ($line =~ /$dev/g)
{
$flag1 = 0;
chomp($line );
#$dir = "$line//trace.txt";
if(-e $line."\\"."traces.txt" )
{
if(-e $line."\\"."capella_whole.log" )
{
#print "capella_whole is in folder\n";
$log = $log+1;
}
if(-e $line."\\"."capella_kernel.log" )
{
#print "capella_kernel is in folder\n";
$log = $log+1;
}

$dir1 = "$line\\traces.txt";
#print "$dir\n";
open(FILE,"<$dir1") or die "cannot open file $!\n";
@data = <FILE>; 

foreach $line1 (@data)
{
#print "$line1\n";
#print " i am inside the file \n";
if($flag1 == 0)
{ 
if( $line1 =~ /pid\s+\d+\s+at/g)
{
$flag1 = 1;
$copy1 = $line1;
@PID_data = split(/at/,$copy1);
}
}
if( $line1 =~ /com.wlan.wlanservice/g or $line1 =~/com.android.bluetooth/ or $line1 =~/com.android.wifi/ or $line1 =~/com.android.wlan/)
{
$copy = 1;
}
}
if ($copy == 1)
{
print "PID is $PID_data[0], Date is $PID_data[1]\n";
#print "traces are in this folders $line\n";
@path = split(/\//,$line);
$size = @path;
#print " $path[$size-1]\n";
$mkdir = "$dir\\$dev";
mkdir $mkdir;
$mkdir = "$dir\\$dev\\$path[$size-1]";
print "$mkdir\n";
mkdir $mkdir;

################## Cpying file to current directory ##################################################################
opendir($DIR, $line) || die "can't opendir $source_dir: $!";  
@files = readdir($DIR);
foreach my $t (@files)
{
   if(-f "$line/$t" ) {
      #Check with -f only for files (no directories)
      copy "$line/$t", "$mkdir/$t";
   }
}
$count = $count+1;
$copy = 0;

if ($log != 2)
{
print "!!!!!!!!!!!!!!!!!!!!!!!! copying logs from logs folder !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n";
opendir($LOG, $LOG_Folder) || die "cannot opendir $LOG_Folder: $!";  
@files = readdir($LOG);
@logs_K_L = grep(/$dev/,@files);
@kmgs = grep(/_kmsg_/,@logs_K_L);
@logcat = grep(/_logcat_/,@logs_K_L);
@hrs = split(/ /,$PID_data[1]);
@date = split(/-/,$hrs[1]);
print"year $date[0]\n month $date[1]\n date $date[2]\n";
@HH = split(/:/,"$hrs[2]");
print"Hrs are $HH[0]\n";
@Actual_Kmgs = grep(/$date[1]-$date[2]-$date[0]_$HH[0]/,@kmgs);
@Actual_logcat = grep(/$date[1]-$date[2]-$date[0]_$HH[0]/,@logcat);
print"@Actual_Kmgs \n@Actual_logcat\n";
foreach my $t (@Actual_Kmgs)
{
   if(-f "$LOG_Folder/$t" ) {
      #Check with -f only for files (no directories)
      copy "$LOG_Folder/$t", "$mkdir/$t";
   }
}
foreach my $t (@Actual_logcat)
{
   if(-f "$LOG_Folder/$t" ) {
      #Check with -f only for files (no directories)
      copy "$LOG_Folder/$t", "$mkdir/$t";
   }
}
}
}
################## Copying Kmgs and logcat to current directory ##################################################################

}
}
}
}
print "Total traces are $count \n";

####################################### Functions #####################################################################
sub uniq {
    my %seen;
    grep !$seen{$_}++, @_;
}