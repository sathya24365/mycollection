
our $Directoryname_source=$ARGV[0];
our $Directoryname_dest=$ARGV[1];
our $meta=$ARGV[2];
our $ptag=$ARGV[3];
our $dump=$ARGV[4];


if ($dump eq 0) 
{
	print "Local copy done\n";
	exit;
}
else 
{ 	
	system("robocopy $Directoryname_source $Directoryname_dest /S /Z /B /ZB /R:300 /W:5");		
	system("crashscope.exe","-batchMode","-metaBuild=$meta","-logDir=$Directoryname_dest","-config=$ptag");
	print "Raising crashscope done\n";
	exit;		
}



