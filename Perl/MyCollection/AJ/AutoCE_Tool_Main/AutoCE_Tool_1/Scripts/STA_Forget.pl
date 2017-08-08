system("adb devices");

print"Enter device id:";
$dev_id=<STDIN>;
chomp($dev_id);

system("adb -s $dev_id shell wlantool -c fgt Hydra");
sleep 1;


print"Press Enter to Continue";
<STDIN>;

