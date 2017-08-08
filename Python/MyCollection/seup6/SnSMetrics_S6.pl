use strict;
no warnings qw(once);
use Data::Dumper;
use File::Path; 
use File::Copy;
use Cwd;   
use File::Basename;
use File::Find;

#***************** Log Directory path for capella.txt ************************************************************************************#
# 1. This will process all the files that are in the $logdir location and add the iterations
#******************************************************************************************************************************************#
print "Crash Log Dir:";
my $logdir = <>;
chomp($logdir);


system("Capella_e_logs_merge.py $logdir");
# <stdin>;

our $strings;
our $num_str;
our @arr_strings=(
'action="ENABLE_WIFI"', 'action="ENABLE_WIFI" status="SUCCESS"',
'action="DISABLE_WIFI"', 'action="DISABLE_WIFI" status="SUCCESS"',
'action="ENABLE_SOFT_AP"', 'action="ENABLE_SOFT_AP" status="SUCCESS"',
'action="DISABLE_SOFT_AP"', 'action="DISABLE_SOFT_AP" status="SUCCESS"',
'action="ENABLE_BLUETOOTH"', 'action="ENABLE_BLUETOOTH" status="SUCCESS"',
'action="DISABLE_BLUETOOTH"', 'action="DISABLE_BLUETOOTH" status="SUCCESS"',
'action="CONNECT_AP"', 'action="CONNECT_AP" status="SUCCESS"',
'action="DISCONNECT_AP"','action="DISCONNECT_AP" status="SUCCESS"',
'action="DIAG_SSR"', 'action="DIAG_SSR" status="SUCCESS"'
);
our $global_param;
my $i;
our @FileMetric; 
$num_str=scalar(@arr_strings);

for($i=0;$i<$num_str;$i++){
	push(@$strings,$arr_strings[$i]);
}	
$global_param->{LOGDIR}=$logdir;
$global_param->{STRINGS}=$strings;
$global_param->{NUM_STRINGS}=$num_str;
processFiles($global_param);

sleep 60;
print "\nPress enter to Exit";
<STDIN>; 

sub processFiles{
	my $param=shift;
	my $logdir=$param->{LOGDIR};
	my $strings=$param->{STRINGS};
	opendir(D, "$logdir") || do{
		print"Can't opedir $logdir: $!\n"
	};
	my @files = readdir(D);
	closedir(D);
	my $file;
	my $itr;
	my $SNo=1;
	my $Iteration=0;
	print "\n________________________________________________________\n";	
	for($itr=0;$itr<$param->{NUM_STRINGS};$itr++){
		foreach $file (@files){
			my $tmp_file=$logdir."\\".$file;
			if(-d $tmp_file){
				next;
			}
			open(FD,$logdir."\\".$file) || do{
			print"Can't open file $tmp_file\n"
				};
			my @lines=<FD>;
			close(FD);
			my $line;
			foreach $line (@lines){
				if($line =~ /$strings->[$itr]/im){
					$Iteration++;
					}
			}
		}
		print "\n $SNo -> $strings->[$itr] = $Iteration times\n";
		$SNo++;
		$Iteration=0;
	}
	print "\n________________________________________________________\n";	
}	
