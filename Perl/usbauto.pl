use MuxMan;


$SIG{INT} = \&stop;

print "_________________________________________\n";
print "     ****Press CTRL+C to stop****\n\n";
print "_________________________________________\n";
print "This is for the USBBOX type";
print "Please input number of ports to control [4:All, 1~4:Custom]:  ";

my $total_ports = <STDIN>;
chomp $total_ports;
my $j=$total_ports;
print "total ports is $total_ports\n";

my @ports;
if ($j != 4)
{
print "which ports you want to control [1~4] ";

	while ($j)
	{
		my $port_num = <STDIN>;
		chomp $port_num;
			if ($port_num<=4)
				{
				push @ports, $port_num;
				my $arr_size=@ports;
				$j--;
				}
			else
				{
				print "Enter a valid port number 1~4 \n";
				}
	}
}
	MuxMan::init(USBBOX);

    print "\nDelay Setting: ".MuxMan::QueryDelaySetting()."\n";
    print "Port Status: [".MuxMan::QueryPortStatus()."]\n";
    
    print "\nSet USB On/Off Delay to 5000ms\n";
    MuxMan::SetUsbOnOffDelay(5000,5000);
    print "Delay Setting: ".MuxMan::QueryDelaySetting()."\n\n";
	print " STARTING USB Auto ON/OFF Funtion \n\n ";

	while(1) {
				foreach my $id (@ports)
					{
						print "USB Port $id ON \n";
						MuxMan::SwitchOnUsb($id);
						logging();
						sahara_copy();
						sleep 10;
						print "USB Port $id OFF \n";
						MuxMan::SwitchOffUsb($id);
						sleep 10;
					}
    print "\n";
	print "\n Waiting @ Home\n";
	sleep 1000;
}


sub logging{
my $sourceDir=;
my $DestDir=;
system ("adb pull $sourceDir  $DestDir");
}

sub sahara_copy{

@months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
@weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);

($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
$year = 1900 + $yearOffset;		
$theTime = "$hour-$minute-$second-$weekDays[$dayOfWeek].$months[$month].$dayOfMonth.$year";	
 
my $Directoryname_source="C:\\ProgramData\\Qualcomm\\QPST\\Sahara";

while(1){ # Need to remove this while loop

	unless(-e $Directoryname_source) {
		print "No crash Detected \n";
		last;
		sleep 1;
	} 

	else {
		
		print "Device went to D-Mode \n";
		
		mkdir ("C:/Sahara"); 
		mkdir ("C:/Sahara/$theTime");
	 
		our $Directoryname_dest="C:\\Sahara\\".$theTime;
		
		system("robocopy $Directoryname_source $Directoryname_dest /S /Z /B /ZB /MOVE /R:300 /W:5");
		
		unless(-e $Directoryname_source){
		
		($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
		$year = 1900 + $yearOffset;		
		$theTime = "$hour-$minute-$second-$weekDays[$dayOfWeek].$months[$month].$dayOfMonth.$year";	
		}
		
		else{	
		print "copying remainning files \n";
		sleep 60;}	
		}

	}
}


sub stop {
    print "Exit Auto USBBOX Control\n";
}


