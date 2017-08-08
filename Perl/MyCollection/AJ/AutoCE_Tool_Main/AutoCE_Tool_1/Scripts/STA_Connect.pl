system("adb devices");

print"Enter device id:";
$dev_id=<STDIN>;
chomp($dev_id);

system("adb -s $dev_id shell wlantool -c won ");

system("adb -s $dev_id shell wlantool -c scn");
sleep 1;

system("adb -s $dev_id shell wlantool -c add AutoCE-SAP SECOPEN");
sleep 1;


print"Press Enter to Continue";
<STDIN>;

