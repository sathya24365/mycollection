system("adb devices");
print"Enter device id:";
$dev_id=<STDIN>;

for($i=0; $i<=10000;$i++)
{
system("adb -s $dev_id wait-for-device root");
system("adb -s $dev_id wait-for-device root");
system("adb -s $dev_id wait-for-device root");

system("adb -s $dev_id shell wlantool -c son");
print "SAP enabled\n";
sleep 1;
system("adb -s $dev_id shell wlantool -c soff");
print "SAP disabled\n";

system("adb -s $dev_id shell wlantool -c won");
print "Wifi enabled\n";
sleep 1;
}

