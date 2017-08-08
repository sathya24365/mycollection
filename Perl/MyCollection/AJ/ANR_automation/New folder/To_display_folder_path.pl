# In this program  we have to read input from user and displaying folder path 
#The g operator for globally find all matches
#The i operator use to ignore case
use warnings;
open (FILE,"log.txt" ) or  die "unable to open"; # to open a  text file.
print "Please enter folder name :";
chomp($line=<STDIN>);
foreach $_ (<FILE>)
 {    
   if ($_ =~ m/\S\b$line/i)
    {	
        print "found $line and file  path is $_ \n";
		#last;
    }
  }

