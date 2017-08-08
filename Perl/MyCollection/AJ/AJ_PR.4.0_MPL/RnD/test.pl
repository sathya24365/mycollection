use Time::Local;
use File::Copy;
use Cwd;
# use Cwd qw(abs_path);


my $serials="1557cc6";
our $cwd=getcwd;

@months = qw(01 02 03 04 05 06 07 08 09 10 11 12);

($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
$year = 1900 + $yearOffset;		
my $date = "$months[$month]-$dayOfMonth-$year";

if ($hour == 1 || $hour == 2 || $hour == 3|| $hour == 4|| $hour == 5|| $hour == 6|| $hour == 7|| $hour == 8|| $hour == 9)
{

$hour= "0".$hour;

}

print $hour;
print "\n";
print $date;
print "\n";


# our $logs_source="c:\\Android"."\\".$date."\\".$serials;

# print $logs_source."\\"."kmsg.txt";
# print "\n";
# print $logs_source."\\"."WifiLogger.txt";
# print "\n";
# print $logs_source."\\".$hour."\\"."logcat.txt";
# print "\n";
# print $cwd."\\"."kmsg.txt";

# eval
# {
  # copy($logs_source."\\"."kmsg.txt", $cwd."\\"."kmsg.txt") or print "\nKMSG File cannot be copied.";
  # copy($logs_source."\\"."WifiLogger.txt", $cwd."\\"."WifiLogger.txt") or print "\nWifiLogger File cannot be copied.";
  # copy($logs_source."\\".$hour."\\"."logcat.txt", $cwd."\\"."logcat.txt") or print "\nlogcat File cannot be copied.";
# };




