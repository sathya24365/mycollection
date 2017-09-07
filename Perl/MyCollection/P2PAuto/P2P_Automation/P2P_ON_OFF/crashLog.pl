
use Time::Local;
use File::Find;


@months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
@weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);

($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
$year = 1900 + $yearOffset;		
$theTime = "$hour-$minute-$second-$weekDays[$dayOfWeek].$months[$month].$dayOfMonth.$year";	
 
my $Directoryname_source="C:\\ProgramData\\Qualcomm\\QPST\\Sahara";

my $i = 1;
 
while(1){

print "loop  $i\n";

unless(-e $Directoryname_source) {
    print "No crash Detected \n";
	($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
	$year = 1900 + $yearOffset;		
	$theTime = "$hour-$minute-$second-$weekDays[$dayOfWeek].$months[$month].$dayOfMonth.$year";	
	sleep 1;} 

else {
    
	print "Device went to D-Mode \n";
	
	mkdir ("C:/Sahara"); 
	mkdir ("C:/Sahara/$theTime");
 
	our $Directoryname_dest="C:\\Sahara\\".$theTime;
	
	system("robocopy $Directoryname_source $Directoryname_dest /S /Z /B /ZB /MOVE /R:300 /W:5");
	
	unless(-e $Directoryname_source) {
	
	($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
	$year = 1900 + $yearOffset;		
	$theTime = "$hour-$minute-$second-$weekDays[$dayOfWeek].$months[$month].$dayOfMonth.$year";	
   
	} 
	
	else{	
	print "copying remainning files \n";
	sleep 60;}	
}

$i = $i+1;

}

