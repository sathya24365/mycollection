use devices;
use Win32::Process;

devices::detect();
devices::display();
$| = 1;

print "\nPlease enter device1 id:";
$device1 = <>;
chomp($device1);

print "\nPlease enter device2 id:";
$device2 = <>;
chomp($device2);

system("mkdir Logs");

Win32::Process::Create( $p3, 'c:/perl/bin/perl.exe', "perl crashLog.pl", 1, CREATE_NEW_CONSOLE, '.', ) or die Win32::FormatMessage( Win32::GetLastError() );
system("perl p2pOnOff.pl $device1 $device2 | tee Logs/stdout.log");
