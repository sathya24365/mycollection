use Win32::Console;
my $CONSOLE = Win32::Console->new(STD_OUTPUT_HANDLE);
my $attr = $CONSOLE->Attr(); # Get current console colors
$CONSOLE->Attr($FG_WHITE | $BG_RED); # Yellow text on green
# print "This is a test\n";
printf "%-30s\n", "@@@@@    @@@  @@    @ @@@@@";
printf "%-30s\n", "@    @  @   @ @ @   @ @    ";
printf "%-30s\n", "@    @  @   @ @  @  @ @@@@ ";
printf "%-30s\n", "@    @  @   @ @   @ @ @    ";
printf "%-30s\n", "@@@@@    @@@  @    @@ @@@@@";

$CONSOLE->Attr($FG_WHITE | $BG_GREEN); # Yellow text on green
# print "This is a test\n";
printf "%-30s\n", "@@@@@    @@@  @@    @ @@@@@";
printf "%-30s\n", "@    @  @   @ @ @   @ @    ";
printf "%-30s\n", "@    @  @   @ @  @  @ @@@@ ";
printf "%-30s\n", "@    @  @   @ @   @ @ @    ";
printf "%-30s\n", "@@@@@    @@@  @    @@ @@@@@";


$CONSOLE->Attr($attr); # Set console colors back to original