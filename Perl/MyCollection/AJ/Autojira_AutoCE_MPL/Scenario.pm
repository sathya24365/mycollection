package Scenario;
use Spreadsheet::ParseExcel;
use Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(Status);
@EXPORT_OK = qw(Status);


sub meta{

	my ($serials) = @_;
	print $serials;
	print "\t";
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
				
				if($col == 1)
				{		
					my $cell = $worksheet->get_cell( $row, $col );
					next unless $cell;			
					if($cell->value() =~ m/$serials/) 
					{ 
						my $cell = $worksheet->get_cell( $row, 3 );
						next unless $cell;
						return $cell->value();
					}
				}
				
			}
		}
	}
}

sub pl{

	my ($serials) = @_;
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
				
				if($col == 1)
				{		
					my $cell = $worksheet->get_cell( $row, $col );
					next unless $cell;			
					if($cell->value() =~ m/$serials/)
					{ 
						my $cell = $worksheet->get_cell( $row, 0 );
						next unless $cell;
						return $cell->value();
					}
				}
				
			}
		}
	}
}
sub tc{

	my ($serials) = @_;
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
				
				if($col == 1)
				{		
					my $cell = $worksheet->get_cell( $row, $col );
					next unless $cell;			
					if($cell->value() =~ m/$serials/)
					{ 
						my $cell = $worksheet->get_cell( $row, 2 );
						next unless $cell;
						return $cell->value();
					}
				}
				
			}
		}
	}
}
sub ext{

	my ($serials) = @_;
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
				
				if($col == 1)
				{		
					my $cell = $worksheet->get_cell( $row, $col );
					next unless $cell;			
					if($cell->value() =~ m/$serials/)
					{ 
						my $cell = $worksheet->get_cell( $row, 4 );
						next unless $cell;
						return $cell->value();
					}
				}
				
			}
		}
	}
}

1;