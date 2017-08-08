use strict;
use warnings;

my $directory = '/tmp';
opendir (DIR, $directory) or die $!;

    while (my $file = readdir(DIR)) {

        print "$file\n";

    }
 closedir(DIR);