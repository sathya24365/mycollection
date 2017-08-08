system("adb devices");
print"Enter device id:";
$dev_id=<STDIN>;
# print"Enter device BT_MAC";
# $BT_MAC=<STDIN>;
$BT_MAC='00:15:83:6B:CE:AC';
# $BT_MAC='FC:58:FA:0A:85:9E';
#chomp($BT_MAC);

for($i=0; $i<=10000;$i++)
{
print "\n**********************Iteration $i *****************\n";

system("adb -s $dev_id shell wlantool -c btbnd $BT_MAC");
sleep 5;
system("adb -s $dev_id shell wlantool -c btubnd $BT_MAC");
sleep 5;

# system("adb -s $dev_id shell wlantool -c btinqon");
# print "BT Inq enabled\n";
# sleep 20;
# system("adb -s $dev_id shell wlantool -c btinqoff");
# print "BT Inq disabled\n";
sleep 2;

}

