system("adb devices");
print"Enter device id:";
$dev_id=<STDIN>;

system("adb -s $dev_id shell wlantool -c son");
print "SAP enabled\n";
sleep 1;

print "SAP Configured as SSID# AutoCE-SAP Sec# Open\n";
system("adb -s $dev_id shell wlantool -c cfgsap open AutoCE-SAP");

print"Press Enter to start SAP On/Off";
<STDIN>;

for($i=0; $i<=10000;$i++)
{
system("adb -s $dev_id wait-for-device root");
system("adb -s $dev_id wait-for-device root");
system("adb -s $dev_id wait-for-device root");

system("adb -s $dev_id shell wlantool -c son");
print "SAP enabled\n";
sleep 5;

system("adb -s $dev_id shell wlantool -c soff");
print "SAP disabled\n";
sleep 300;

}




