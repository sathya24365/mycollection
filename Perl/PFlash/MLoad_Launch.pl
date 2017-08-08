use Cwd;
use File::Path; 
# use File::pushd;
use Win32::Console;
use Spreadsheet::ParseExcel;
use XML::Simple;
use Data::Dumper;
use Term::ReadKey;

our $OUT = Win32::Console->new(STD_OUTPUT_HANDLE);
our $xml = new XML::Simple;
our $cwd = getcwd;

our @labm;
our @labm2;
our @hwid;
our @meta;
our @apps;
our @fw;
our @tz;
our @rpm;
our @boot;
our @capella;
our @tools;

cls();
print "\nEnter user::";
chomp (our $usr = ReadLine(0));
ReadMode('noecho');
print "\nEnter password::";
chomp (our $psw = ReadLine(0));
cls();
get_build();
print "\n Press any key to continue...\n";
<STDIN>;
# hwmonitor();
# print "\n Press any key to continue...\n";
# <STDIN>;

launch();
print "\n\n";
printf "%-40s\n", "@@@@@    @@@  @@    @ @@@@@";
printf "%-40s\n", "@    @  @   @ @ @   @ @    ";
printf "%-40s\n", "@    @  @   @ @  @  @ @@@@ ";
printf "%-40s\n", "@    @  @   @ @   @ @ @    ";
printf "%-40s\n", "@@@@@    @@@  @    @@ @@@@@";
print "\n\n Press enter to Exit....";
<STDIN>;

###############################################################



sub launch{	

	my $temp_labm=0;
	for (my $i=0; $i<@hwid; $i++)
	{
		
		my $cmd_launch="PsExec.exe \\\\$labm[$i] -w  C:\\Dropbox\\Pflash cmd /K MLoad.pl $hwid[$i] $meta[$i] $apps[$i] $fw[$i] $capella[$i] $tools[$i]";
		my $hope_location= '\\\\hope\\SNS-ODC-TESTING\\1-Reference\\1-All_in_One\\SDM660\\ADDON';
		
		if ($meta[$i] ne 'NA')
		{
			if ($temp_labm eq $labm[$i])
			{			
				print "$labm[$i] duplicate\n";
				system("start cmd /k $cmd_launch");
				sleep 2;

			}else {				

				$temp_labm=$labm[$i];
				print"*****************************************************************\n";
				my $cmd_copy="xcopy MLoad.pl \\\\$labm[$i]\\Dropbox\\Pflash\\ /Y";
				
				# my $cmd_xdelete="PsExec.exe \\\\$labm[$i] net use x: /delete";
				# my $cmd_ydelete="PsExec.exe \\\\$labm[$i] net use y: /delete";
				# my $cmd_zdelete="PsExec.exe \\\\$labm[$i] net use z: /delete";
				# my $cmd_pdelete="PsExec.exe \\\\$labm[$i] net use p: /delete";
				# my $cmd_qdelete="PsExec.exe \\\\$labm[$i] net use q: /delete";
				my $cmd_delete="PsExec.exe \\\\$labm[$i] net use * /delete /yes";
				
				my $cmd_meta="PsExec.exe"." \\\\$labm[$i] -w  C:\\Dropbox\\Pflash net use x: ".$meta[$i]." ".$psw." /USER:".$usr." /p:YES";
				my $cmd_tz="PsExec.exe"." \\\\$labm[$i] -w  C:\\Dropbox\\Pflash net use y: ".$tz[$i]." ".$psw." /USER:".$usr." /p:YES";
				my $cmd_rpm="PsExec.exe"." \\\\$labm[$i] -w  C:\\Dropbox\\Pflash net use z: ".$rpm[$i]." ".$psw." /USER:".$usr." /p:YES";
				my $cmd_boot="PsExec.exe"." \\\\$labm[$i] -w  C:\\Dropbox\\Pflash net use p: ".$boot[$i]." ".$psw." /USER:".$usr." /p:YES";
				my $cmd_hope="PsExec.exe"." \\\\$labm[$i] -w  C:\\Dropbox\\Pflash net use q: ".$hope_location." ".$psw." /USER:".$usr." /p:YES";
				
				my $cmd_monitor="PsExec.exe \\\\$labm[$i] net use";			
				
				system($cmd_copy);
				cls();
				# system($cmd_xdelete);
				# sleep 1;
				# system($cmd_ydelete);
				# sleep 1;
				# system($cmd_zdelete);	
				# sleep 1;				
				# system($cmd_pdelete);	
				# sleep 1;
				# system($cmd_qdelete);	
				# sleep 1;
				system($cmd_delete);	
				sleep 1;
				cls();
				system($cmd_meta);
				sleep 2;
				system($cmd_tz);
				sleep 2;
				system($cmd_rpm);	
				sleep 2;
				system($cmd_boot);	
				sleep 2;
				system($cmd_hope);	
				sleep 2;
				cls();
				system($cmd_monitor);	
				sleep 2;
				# print "\nPress enter to Continue....";
				# <STDIN>;
				system("start cmd /k $cmd_launch");
				sleep 2;
			
			}
		}else{
			# print "$labm[$i] $hwid[$i] DUT flashing has been skipped\n";
			print"";
		}
		
	}	
}

sub get_build{

    my $parser   = Spreadsheet::ParseExcel->new();
    my $workbook = $parser->parse('SDM660.xls');

    if ( !defined $workbook ) {
        die $parser->error(), ".\n";
    }
	
	for my $worksheet ( $workbook->worksheets() ) {
		
		my ( $row_min, $row_max ) = $worksheet->row_range();
		my ( $col_min, $col_max ) = $worksheet->col_range();
		
		$row_min=$row_min+1;
		$col_min=$col_min+1;

		for my $row ( $row_min .. $row_max ) {
			for my $col ( $col_min .. $col_max ) {
				
				if($col eq 1) 
				{ 
					my $cell = $worksheet->get_cell( $row, $col );
					next unless $cell;

					# print $cell->value();
					# print "\n";
					if(!$cell->value() eq ''){
					
						push (@labm,$cell->value());
						chomp @labm;
					}else{					
						print "\nUpdate sheet properly@ $row, $col....";
						exit;
					}
				}
				elsif($col eq 2)
				{		
					my $cell = $worksheet->get_cell( $row, $col );
					next unless $cell;			
					# print $cell->value();
					# print "\n";
					if(!$cell->value() eq ''){
					
						push (@hwid,$cell->value());
						chomp @hwid;
					}else{					
						print "\nUpdate sheet properly@ $row, $col....";
						exit;
					}					
				}
				elsif($col eq 3)
				{		
					my $cell = $worksheet->get_cell( $row, $col );
					next unless $cell;			
					# print $cell->value();
					# print "\n";
					if(!$cell->value() eq ''){
					
						push (@meta,$cell->value());
						chomp @meta;						
					}else{					
						push (@meta,'NA');
						chomp @meta;
					}
				}	
				elsif($col eq 4)
				{		
					my $cell = $worksheet->get_cell( $row, $col );
					next unless $cell;			
					# print $cell->value();
					# print "\n";
					if(!$cell->value() eq ''){
					
						push (@apps,$cell->value());
						chomp @apps;
					}else{					
						push (@apps,'NA');
						chomp @apps;
					}					
				}	
				elsif($col eq 5)
				{		
					my $cell = $worksheet->get_cell( $row, $col );
					next unless $cell;			
					# print $cell->value();
					# print "\n";
					if(!$cell->value() eq ''){
					
						push (@fw,$cell->value());
						chomp @fw;
					}else{					
						push (@fw,'NA');
						chomp @fw;
					}					
				}
				elsif($col eq 6)
				{		
					my $cell = $worksheet->get_cell( $row, $col );
					next unless $cell;			
					# print $cell->value();
					# print "\n";
					if(!$cell->value() eq ''){
					
						push (@capella,$cell->value());
						chomp @capella;
					}else{					
						push (@capella,'NA');
						chomp @capella;
					}					
				}	
				elsif($col eq 7)
				{		
					my $cell = $worksheet->get_cell( $row, $col );
					next unless $cell;			
					# print $cell->value();
					# print "\n";
					if(!$cell->value() eq ''){
					
						push (@tools,$cell->value());
						chomp @tools;
					}else{					
						push (@tools,'NA');
						chomp @tools;
					}					
				}				
			}
		}
	}
	
for (my $i=0; $i<@hwid; $i++)
{	
	if ($meta[$i] ne 'NA')
	{
		$contents=$meta[$i]."\\contents.xml";

		my $data = $xml->XMLin($contents) or die "Sorry no can do:$!";
		# print $data->{ builds_flat }->{ build }->{ tz }->{ windows_root_path }->{ content };
		# print "\n";
		my $tzpath=$data->{ builds_flat }->{ build }->{ tz }->{ windows_root_path }->{ content };
		my $rpmpath=$data->{ builds_flat }->{ build }->{ rpm }->{ windows_root_path }->{ content };
		my $bootpath=$data->{ builds_flat }->{ build }->{ boot }->{ windows_root_path }->{ content };
		chop $tzpath;
		chop $rpmpath;
		chop $bootpath;
		push (@tz,$tzpath);
		push (@rpm,$rpmpath);
		push (@boot,$bootpath);
		chomp @tz;
		chomp @rpm;
		chomp @boot;
	}else{
		push (@tz,'NA');
		push (@rpm,'NA');
		push (@boot,'NA');
	}
}
	# for (my $i=0; $i<@hwid; $i++)
	# {
		# print "$tz[$i]\n";
		# print "$rpm[$i]\n";
		# print "$boot[$i]\n";
	# }
	
	printf "%-10s%-10s%-70s%-10s%-10s\n", "LAB","HWID","META","CAPELLA","TOOLS";
	printf "%-10s%-10s%-70s%-10s%-10s\n", "---","----","----","-------","-----";
	
	for (my $i=0; $i<@hwid; $i++)
	{
		if ($meta[$i] ne 'NA')
		{
			printf "%-10s%-10s%-70s%-10s%-10s\n", $labm[$i], $hwid[$i], $meta[$i], $capella[$i], $tools[$i];
			push (@labm2,$labm[$i]);
		}
	}
	
	print "\n";
}

sub hwmonitor{	

my @adblist;
my @fblist;

	# while(1)
	# {		
		cls();
		my $temp_labm=0;
		foreach (@labm2)
		{
			if ($temp_labm eq $_)
			{		
				print "\n$_ duplicate";
			}else {	
				$temp_labm=$_;				
				@$_;
				my $adbdevices="PsExec.exe \\\\$_ -s cmd /c adb devices";
				my @data=qx($adbdevices);	
				foreach (@data)
				{
					my $adbid = $_;
					if ($adbid =~ m/(\S+)\s+device$/)
					{
						$adbid =~ m/(\S+)\s+device/;
						push(@$_, $1);
					}
				}
				print @data;
				undef @data;
				# cls();
				print "\nDetected ADB Devices are::";
				foreach (@adblist)
				{
					print "\n$_";
				}
				undef @adblist;
					
				my $fbdevices="PsExec.exe \\\\$_ -s cmd /c fastboot devices";
				my @data=qx($fbdevices);
				
				foreach (@data)
				{
					my $fbid = $_;
					if ($fbid =~ m/(\S+)\s+fastboot$/)
					{
						push(@fblist, $1);
					}
				}
				undef @data;
				# cls();
				print "\nDetected FB Devices are::";
				foreach (@data)
				{
					print "\n$_";
				}
				undef @fblist;
			}
		}
	# }
}

sub cls{
	our $clear_string = $OUT->Cls;
	print $clear_screen;
}