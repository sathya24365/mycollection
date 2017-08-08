use Getopt::Long;
use Win32::OLE;
use Win32::OLE::Variant;


print "Enter Comport:";
my $x = <>;
chomp($x);
my $ComPort = "com$x";


print "Enter TC Name:";
my $TC = <>;

chomp($TC);

print "\n";

print "Selected COM port:$ComPort\n";
print "Running Test Case:$TC";

print "\nPress enter to Continue....";
system("title $port$TC");
<STDIN>;
my $i = 1;
        
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
  $port = $qpst->GetPort($ComPort);

 %phone_status_list = qw (
    0 phoneStatusNone
    5 phoneStatusReady) ;

  if (defined $port)
  {
    $port_name = $port->PortName;

    $port_status = $port->PhoneStatus;
	 $port_mode = $port->PhoneMode;
   
	 my $count = 1;
	 
	 mkdir ("c:/RAMDUMPS");
	 
	 mkdir ("c:/RAMDUMPS/$TC");
    
	while (1)
	 {

		 if ($phone_status_list{$port_status} eq "phoneStatusReady" && $port_mode eq 2)
		 {
		 
			print "Phone in Download Mode\n";
			my $memory_debug = $port->{MemoryDebug};
			
			  $memory_debug->{UseUnframedMemoryRead} = 1;

			if (defined $memory_debug)
			{
				
				my $dir='c:/RAMDUMPS/$TC/DUMP_$i';

				unless(-d $dir)
				{

				mkdir ("c:/RAMDUMPS/$TC/DUMP_$i");
				
				print "Wait for 20Min, Saving Ramdump to folder c:/RAMDUMPS/$TC/DUMP_$i\n";
				
				$memory_debug->SaveAllRegions("c:/RAMDUMPS/$TC/DUMP_$i");
				print "Crash dump saved, reset device.\n";
				$port->Reset();				
				
				}
				
			}
			else
			{
			  print "No MemoryDebug interface for this port\n";
			}
			
			$i = $i+1;

			undef $memory_debug;
			$port_status = $port->PhoneStatus;
			$port_mode = $port->PhoneMode;
			
		 }
		 else
		 {
			if($count>0)
			{
				print "Phone not ready or not in download mode\n";
				sleep 60;
				$port_status = $port->PhoneStatus;
				$port_mode = $port->PhoneMode;
			}
			else
			{
				print "Phone still not ready or not in download mode, quit.\n";
				last;
			}
		 }

		 $count = $count+1;
	 }
  }
  else
  {
    print "Port not available\n";
  }

  undef $port;
}
else
{
  print "QPST not available\n";
}

undef $qpst;

print "\nPress enter to Exit";
<STDIN>; 

