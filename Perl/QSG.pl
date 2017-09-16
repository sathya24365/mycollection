use Win32::Console;
use Spreadsheet::ParseExcel;


our @com;
our @tc;

status();
print "\nPress any key to continue...\n";
<STDIN>;
our $OUT = Win32::Console->new(STD_OUTPUT_HANDLE);


while(1)
{

	our $clear_string = $OUT->Cls;
	print $clear_screen;

	for (my $i=0; $i<@com; $i++) 
	{

	# my $tc=Scenario::tc($com[$i]);
	
	my $Directoryname_source="C:\\ProgramData\\Qualcomm\\QPST\\Sahara\\Port_$com[$i]";
	my $Directoryname_source2="C:\\ProgramData\\Qualcomm\\QPST\\Sahara\\Port_$com[$i]\\dump_info.txt";
	my $Directoryname_file="C:\\ProgramData\\Qualcomm\\QPST\\Sahara\\Port_$com[$i]\\Scenario.txt";

		if(-e $Directoryname_source && -e $Directoryname_source2)
		{
			# print "$tc\n";
			# print "$Directoryname_file\n";
			if(!-e $Directoryname_file)
			{
				print "Scenario.txt is being copied in Port_$com[$i]....\n";
				open(DATA, ">$Directoryname_source/Scenario.txt");
				print DATA $tc[$i];
				close( DATA );
			
			}
			else
			{
			
				print "Scenario.txt is already copied in Port_$com[$i]....\n";
			
			}				
		}
		else
		{
		
			print "No crash on $com[$i]\n";
		
		}
	}
	sleep 10;
}

sub status{

    my $parser   = Spreadsheet::ParseExcel->new();
    my $workbook = $parser->parse('Book.xls');

    if ( !defined $workbook ) {
        die $parser->error(), ".\n";
    }

	for my $worksheet ( $workbook->worksheets() ) {
		
		my ( $row_min, $row_max ) = $worksheet->row_range();
		my ( $col_min, $col_max ) = $worksheet->col_range();

		for my $row ( $row_min .. $row_max ) {
			for my $col ( $col_min .. $col_max ) {
				
				if($col eq 0) 
				{ 
					my $cell = $worksheet->get_cell( $row, $col );
					next unless $cell;

					# print $cell->value();
					# print "\n";
					if(!$cell->value() eq ''){
					
						push (@com,$cell->value());
						chomp @com;
					}

				}
				elsif($col eq 1)
				{		
					my $cell = $worksheet->get_cell( $row, $col );
					next unless $cell;			
					# print $cell->value();
					# print "\n";
					if(!$cell->value() eq ''){
					
						push (@tc,$cell->value());
						chomp @tc;
						
					}					
				}				
			}
		}
	}
	
	for (my $i=0; $i<@com; $i++)
	{
		print "$com[$i]\n";
	}
	print "\n";
	for (my $i=0; $i<@tc; $i++)
	{
		print "$tc[$i]\n";
	}	
	print "\n";	
}