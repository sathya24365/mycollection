use XML::Simple;
use Data::Dumper;

my $xml = new XML::Simple;
my $meta="\\\\diwali\\nsid-hyd-04\\SDM660.LA.1.0.c2-20255-INT-1";
$meta=$meta."\\contents.xml";
print "\n$meta";
print "\n";



my $data = $xml->XMLin($meta) or die "Sorry no can do:$!";

print $data->{ builds_flat }->{ build }->{ tz }->{ windows_root_path }->{ content };
# print Dumper($data);
exit;

