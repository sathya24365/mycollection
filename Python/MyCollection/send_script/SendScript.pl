# NOTE: This script must be run from a command box,
# i.e.  Perl QXDMSendScript.pl [COM Port Number]

# This script demonstrates usage of the QXDM automation
# interface method SendScript for sending QXDM Commands

use strict;
use warnings;
no warnings qw(once);

use Win32::OLE::Variant;

#  Miscellaneous constants
use constant null                => 0;
use constant false               => 0;
use constant true                => 1;

# DIAG server states
use constant SERVER_DISCONNECTED  => 0;
use constant SERVER_CONNECTED     => 2;

# Global variable
my $IQXDM;
my $IQXDM2;

# COM port to be used for communication with the phone by QXDM
my $PortNumber = -1;
my $Cmd = "";

# Process the argument - port number and command
sub ParseArguments
{
   # Assume failure
   my $RC = false;
   my $Help = "Syntax: Perl QXDMSendScript.pl [COM Port Number] [Command]\n"
            . "Eg:     Perl QXDMSendScript.pl 17 \"send_data 75 37 03 32 01 10\"\n";

   if ($#ARGV < 1)
   {
      # COM port and Command are mandatory
	  print "\nError: COM Port and Command are mandatory\n";
	  print "\n$Help\n";
      return $RC;
   }

   $PortNumber = $ARGV[0];
   $Cmd = $ARGV[1];
   
   # Disable this check as port number can be greater than 100
   # if ($PortNumber < 1 || $PortNumber > 100)
   # {
      # print "\nInvalid port number\n";
      # print "\n$Help\n";
      # return $RC;
   # }

   # Success
   $RC = true;
   return $RC;
}

# Initialize application
sub Initialize
{
   # Assume failure
   my $RC = false;

   # Create QXDM object
   $IQXDM = new Win32::OLE 'QXDM.Application';
   if ($IQXDM == null)
   {
      print "\nError launching QXDM";
	  return $RC;
   }
   
   # Create QXDM2 interface
   $IQXDM2 = $IQXDM->GetIQXDM2();
   if ($IQXDM2 == null)
   {
      print "\nQXDM does not support required interface";
      return $RC;
   }
   
   # Success
   $RC = true;
   return $RC;
}

# Connect to our desired port
sub Connect
{
   # Assume failure
   my $RC = false;
   my $Txt = "";

   if ($PortNumber == 0)
   {
      $Txt = "Invalid COM port specified" . $PortNumber;
      print( "\n$Txt\n" );

      return $RC;
   }

   # Connect to our desired COM port
   $IQXDM->{COMPort} = $PortNumber;

   # Wait until DIAG server state transitions to connected
   # (we do this for up to five seconds)
   my $WaitCount = 0;
   my $ServerState = SERVER_DISCONNECTED;
   while ($ServerState != SERVER_CONNECTED && $WaitCount < 5)
   {
      sleep( 1 );

      $ServerState = $IQXDM2->GetServerState();
      $WaitCount++;
   }

   if ($ServerState == SERVER_CONNECTED)
   {
      # Success!
      $Txt = "QXDM connected to COM" . $PortNumber;
      print( "\n$Txt\n" );
      $RC = true;
   }
   else
   {
      $Txt = "QXDM unable to connect to COM" . $PortNumber;
      print( "\n$Txt\n" );
   }

   return $RC;
}

# Send QXDM command 
sub SendCommand
{   
   print "\nSending command : $Cmd\n";
   $IQXDM->SendScript($Cmd);
   
   # Wait for Cmd Execution
   print "\nExecuting command on QXDM\n";
   sleep( 5 );
}

# Disconnect from our desired port
sub Disconnect
{
   # Assume failure
   my $RC = false;

   # Disconnect
   $IQXDM->{COMPort} = 0;

   # Wait until DIAG server state transitions to disconnected
   # (we do this for up to five seconds)
   my $WaitCount = 0;
   my $ServerState = SERVER_CONNECTED;
   while ($ServerState != SERVER_DISCONNECTED && $WaitCount < 5)
   {
      sleep( 1 );

      $ServerState = $IQXDM2->GetServerState();
      $WaitCount++;
   }

   my $Txt = "";
   if ($ServerState == SERVER_DISCONNECTED)
   {
      # Success!
      $Txt = "QXDM successfully disconnected";
      print( "\n$Txt\n" );
      $RC = true;
   }
   else
   {
      $Txt = "QXDM unable to disconnect";
      print( "\n$Txt\n" );
   }

   return $RC;
}

# Main body of script
sub Execute
{
   # Parse out arguments
   my $RC = ParseArguments();
   if ($RC == false)
   {
      return;
   }

   # Launch QXDM
   $RC = Initialize();
   if ($RC == false)
   {
      return;
   }

   # Get QXDM version
   my $Version = $IQXDM->{AppVersion};
   print "\nQXDM Version: " . $Version . "\n";
   
   # Connect to our desired port
   $RC = Connect();
   if ($RC == false)
   {
      return;
   }
   
   # Send QXDM command 
   SendCommand();
   
   # Disconnect from our desired port
   $RC = Disconnect();
   if ($RC == false)
   {
      return;
   }
   
	# Quit QXDM
	print "\nQuit QXDM\n";
	$IQXDM->QuitApplication();
}

Execute();