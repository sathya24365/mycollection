use strict;
use warnings;
my $iteration = 500000;

system("adb devices");
print "Enter Device ID:";
my $x = <>;
chomp($x);

print "Waiting for Device....";
system("adb -s $x wait-for-device root");

for(my $i=0;$i<$iteration;$i++){

system("adb -s $x wait-for-device root");

print"\n Runnning iteration number : $i\n ";

system("adb -s $x shell wpa_cli ifname=wlan0 disconnect");
sleep 1;

system("adb -s $x shell wpa_cli ifname=wlan0 reconnect");
sleep 1;

# print"End of iteration $i";
}
