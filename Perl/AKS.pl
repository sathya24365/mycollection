use strict;
use warnings;
system("adb devices");
while(1)
{
my $aray = `adb devices`;
print "$aray";
if($aray =~ /\* daemon not running./g){
system('devcon restart *USB\VID_*');
system('devcon rescan');
system('taskkill /f /im adb.exe /t');
}
}
